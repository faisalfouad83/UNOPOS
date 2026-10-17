import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/offline/connectivity.dart';
import '../../../core/offline/offline_cache.dart';
import '../../../core/providers.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../inventory/data/product_image_store.dart';
import '../data/price_catalog_source.dart';
import '../data/price_snapshot_store.dart';
import '../domain/price_snapshot.dart';

/// What the status line says, from most to least pressing.
enum PriceCheckerStatus {
  /// Opening the saved snapshot.
  loading,

  /// Downloading products right now.
  syncing,

  /// No snapshot on this device and no connection: one online
  /// synchronization is needed before prices can be shown.
  needsInitialSync,

  /// Offline: prices come from the saved snapshot.
  offline,

  /// The last attempt failed: prices come from the previous snapshot.
  failed,

  /// Refreshed successfully a moment ago: the latest prices.
  current,

  /// Online, but the snapshot shown is an older one that hasn't been
  /// refreshed yet in this session (or not for a while).
  saved,
}

class PriceCheckerState {
  const PriceCheckerState({
    required this.meta,
    this.snapshot,
    this.index,
    this.loaded = false,
    this.syncing = false,
    this.online = true,
    this.refreshedThisRun = false,
    this.imagesVersion = 0,
  });

  final PriceSnapshotMeta meta;
  final PriceSnapshot? snapshot;
  final PriceIndex? index;
  final bool loaded;
  final bool syncing;
  final bool online;

  /// The snapshot shown was downloaded during this run of the app (and
  /// the latest attempt succeeded). A snapshot read from disk is never
  /// "current" until it has been refreshed.
  final bool refreshedThisRun;

  /// Changes whenever new product photos were saved.
  final int imagesVersion;

  bool get hasSnapshot => snapshot != null;

  PriceCheckerState copyWith({
    PriceSnapshotMeta? meta,
    PriceSnapshot? snapshot,
    PriceIndex? index,
    bool? loaded,
    bool? syncing,
    bool? online,
    bool? refreshedThisRun,
    int? imagesVersion,
  }) =>
      PriceCheckerState(
        meta: meta ?? this.meta,
        snapshot: snapshot ?? this.snapshot,
        index: index ?? this.index,
        loaded: loaded ?? this.loaded,
        syncing: syncing ?? this.syncing,
        online: online ?? this.online,
        refreshedThisRun: refreshedThisRun ?? this.refreshedThisRun,
        imagesVersion: imagesVersion ?? this.imagesVersion,
      );

  /// The snapshot is the latest one: refreshed in this run, the last try
  /// succeeded, still online, and not longer ago than [maxAge]. Being
  /// online alone never makes an old snapshot current.
  bool isCurrent(DateTime now, {Duration maxAge = PriceCheckerController.currentFor}) {
    final last = meta.lastSuccessfulSync;
    return hasSnapshot &&
        online &&
        refreshedThisRun &&
        meta.lastResult == PriceSyncResult.success &&
        last != null &&
        now.difference(last) <= maxAge;
  }

  PriceCheckerStatus status(DateTime now) {
    if (!loaded) return PriceCheckerStatus.loading;
    if (syncing) return PriceCheckerStatus.syncing;
    if (!hasSnapshot && !online) return PriceCheckerStatus.needsInitialSync;
    if (!online) return PriceCheckerStatus.offline;
    if (meta.lastResult == PriceSyncResult.failed) return PriceCheckerStatus.failed;
    if (isCurrent(now)) return PriceCheckerStatus.current;
    return PriceCheckerStatus.saved;
  }
}

/// Keeps one store's price snapshot: opens the saved one at once (lookups
/// never wait for the network), then refreshes it on start, whenever the
/// connection comes back, every [period], and on request. A refresh
/// replaces the snapshot only when the download is complete and valid;
/// otherwise the previous snapshot stays and the failure is noted.
class PriceCheckerController extends StateNotifier<PriceCheckerState> {
  PriceCheckerController({
    required this.storeId,
    required PriceSnapshotStore store,
    required PriceCatalogSource source,
    bool online = true,
    Duration? period = defaultPeriod,
    DateTime Function()? clock,
    void Function()? onNetworkError,
    bool autoStart = true,
  })  : _store = store,
        _source = source,
        _clock = clock ?? DateTime.now,
        _onNetworkError = onNetworkError,
        super(PriceCheckerState(meta: PriceSnapshotMeta(storeId: storeId), online: online)) {
    if (period != null) _timer = Timer.periodic(period, (_) => sync());
    if (autoStart) _ready = _start();
  }

  static const Duration defaultPeriod = Duration(minutes: 10);

  /// How long after a successful refresh the snapshot still counts as the
  /// latest (a little over one refresh period).
  static const Duration currentFor = Duration(minutes: 15);

  final String storeId;
  final PriceSnapshotStore _store;
  final PriceCatalogSource _source;
  final DateTime Function() _clock;
  final void Function()? _onNetworkError;
  Timer? _timer;
  Future<void>? _running;
  Future<void>? _ready;

  /// Completes once the saved snapshot has been opened (and the first
  /// refresh, if online, has finished).
  Future<void> get ready => _ready ?? Future.value();

  Future<void> _start() async {
    await openSaved();
    if (mounted && state.online) await sync();
  }

  /// Opens the snapshot saved on this device for [storeId].
  Future<void> openSaved() async {
    final snapshot = await _store.loadSnapshot(storeId);
    final meta = await _store.loadMeta(storeId);
    if (!mounted) return;
    state = PriceCheckerState(
      meta: meta,
      snapshot: snapshot,
      index: snapshot == null ? null : PriceIndex(snapshot.products),
      loaded: true,
      syncing: state.syncing,
      online: state.online,
    );
  }

  void setOnline(bool online) {
    if (!mounted || state.online == online) return;
    state = state.copyWith(online: online);
    if (online) unawaited(sync());
  }

  /// Downloads the store's products and replaces the snapshot. Runs one at
  /// a time; a call while one is running waits for it instead.
  Future<void> sync() {
    if (!mounted) return Future.value();
    return _running ??= _sync().whenComplete(() => _running = null);
  }

  Future<void> _sync() async {
    final startedAt = _clock();
    state = state.copyWith(syncing: true);
    final previous = state.snapshot;
    var meta = state.meta;
    try {
      final products = await _source.fetchActiveProducts(storeId).timeout(const Duration(minutes: 2));
      if (products.isEmpty && previous != null && previous.productCount > 0) {
        // A store's whole catalogue never vanishes in one go; more likely
        // the request answered for the wrong account. Keep what we have.
        throw StateError('the server returned no products');
      }
      final version = (previous?.version ?? 0) > meta.version ? previous!.version : meta.version;
      final candidate = PriceSnapshot(
        storeId: storeId,
        snapshotId: const Uuid().v4(),
        version: version + 1,
        createdAt: startedAt,
        products: products,
      );
      final saved = await _store.replaceSnapshot(candidate);
      meta = meta.copyWith(
        snapshotId: saved.snapshotId,
        version: saved.version,
        createdAt: saved.createdAt,
        lastSuccessfulSync: startedAt,
        lastAttempt: startedAt,
        productCount: saved.productCount,
        lastResult: PriceSyncResult.success,
        clearError: true,
      );
      await _saveMeta(meta);
      if (!mounted) return;
      state = state.copyWith(
        snapshot: saved,
        index: PriceIndex(saved.products),
        meta: meta,
        syncing: false,
        refreshedThisRun: true,
        loaded: true,
      );
      await _syncImages(saved);
    } catch (e) {
      if (isNetworkError(e)) _onNetworkError?.call();
      meta = meta.copyWith(lastAttempt: startedAt, lastResult: PriceSyncResult.failed, lastError: _short(e));
      await _saveMeta(meta);
      if (!mounted) return;
      state = state.copyWith(meta: meta, syncing: false, refreshedThisRun: false, loaded: true);
    } finally {
      if (mounted && state.syncing) state = state.copyWith(syncing: false);
    }
  }

  static String _short(Object e) {
    final text = e.toString();
    return text.length > 200 ? text.substring(0, 200) : text;
  }

  Future<void> _saveMeta(PriceSnapshotMeta meta) async {
    try {
      await _store.saveMeta(meta);
    } catch (_) {
      // The snapshot still works; the notes are just not updated.
    }
  }

  /// Saves a copy of every photo not saved yet, then deletes copies no
  /// product uses any more. Best effort: a missing photo never fails the
  /// refresh (it is tried again next time).
  Future<void> _syncImages(PriceSnapshot snapshot) async {
    final paths = {
      for (final p in snapshot.products)
        if (p.imagePath != null && p.imagePath!.isNotEmpty) p.imagePath!,
    };
    var added = 0;
    for (final path in paths) {
      if (!mounted) return;
      try {
        if (await _store.hasImage(storeId, path)) continue;
        final bytes = await _source.fetchImage(path);
        if (bytes == null || bytes.isEmpty) continue;
        await _store.saveImage(storeId, path, bytes);
        added++;
      } catch (_) {}
    }
    await _store.pruneImages(storeId, paths);
    if (added > 0 && mounted) state = state.copyWith(imagesVersion: state.imagesVersion + 1);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final priceSnapshotStoreProvider = Provider<PriceSnapshotStore>((ref) => PriceSnapshotStore());

final priceCatalogSourceProvider = Provider<PriceCatalogSource>((ref) {
  final images = ref.watch(productImageStoreProvider);
  if (kUseSupabaseBackend) return SupabasePriceCatalogSource(ref.watch(supabaseClientProvider), images);
  return RepositoryPriceCatalogSource(ref.watch(inventoryRepositoryProvider), images);
});

/// The price checker of one store (by id); closed when the screen closes.
final priceCheckerControllerProvider =
    StateNotifierProvider.autoDispose.family<PriceCheckerController, PriceCheckerState, String>((ref, storeId) {
  final controller = PriceCheckerController(
    storeId: storeId,
    store: ref.watch(priceSnapshotStoreProvider),
    source: ref.watch(priceCatalogSourceProvider),
    online: ref.read(connectivityProvider),
    onNetworkError: () => ref.read(connectivityProvider.notifier).markOffline(),
  );
  ref.listen<bool>(connectivityProvider, (_, online) => controller.setOnline(online));
  return controller;
});
