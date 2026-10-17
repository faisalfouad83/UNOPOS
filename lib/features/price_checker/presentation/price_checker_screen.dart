import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/barcode_input_field.dart';
import '../../../core/widgets/unopos_logo.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/product_units.dart';
import '../../pos/presentation/scan_search_field.dart';
import '../application/price_checker_controller.dart';
import '../domain/price_snapshot.dart';
import 'price_checker_exit_dialog.dart';

/// The label the store owner asked for above the product's identifier,
/// kept in English in every language on purpose.
const String priceCheckerSerialLabel = 'Serial Number';

/// The dedicated, read-only price checker: a full-screen kiosk for
/// customers to scan a product and see its price. Works from the snapshot
/// saved on the device, so it keeps working offline; nothing else in the
/// app can be reached from here (see RouteGuard).
class PriceCheckerScreen extends ConsumerWidget {
  const PriceCheckerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(sessionControllerProvider.select((s) => s.store));
    if (store == null) return const Scaffold(body: SizedBox.shrink());
    return PriceCheckerView(storeId: store.id, storeName: store.displayName);
  }
}

/// The price checker for one store (separate from [PriceCheckerScreen] so
/// it can be shown without a signed-in session in tests).
class PriceCheckerView extends ConsumerStatefulWidget {
  const PriceCheckerView({super.key, required this.storeId, required this.storeName});

  final String storeId;
  final String storeName;

  /// A shown result clears itself after this long without any activity.
  static const Duration idleTimeout = Duration(seconds: 30);

  @override
  ConsumerState<PriceCheckerView> createState() => _PriceCheckerViewState();
}

class _PriceCheckerViewState extends ConsumerState<PriceCheckerView> {
  final _search = TextEditingController();
  final _focus = FocusNode();
  PriceLookup? _result;
  Timer? _idle;

  /// Re-draws the status now and then, so "latest" turns into "older" on
  /// its own when refreshing stops.
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _idle?.cancel();
    _clock?.cancel();
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _touch() {
    _idle?.cancel();
    if (_result == null && _search.text.isEmpty) return;
    _idle = Timer(PriceCheckerView.idleTimeout, () {
      if (!mounted) return;
      _search.clear();
      setState(() => _result = null);
    });
  }

  PriceIndex? get _index => ref.read(priceCheckerControllerProvider(widget.storeId)).index;

  Future<void> _onScan(String code) async {
    final index = _index;
    if (index == null || code.trim().isEmpty) return;
    setState(() => _result = index.lookup(code));
    _touch();
  }

  void _onChanged(String text) {
    final index = _index;
    setState(() {
      if (text.trim().length < 2 || index == null) {
        if (_result is PriceChoices && !(_result as PriceChoices).exact) _result = null;
      } else {
        final matches = index.search(text);
        _result = matches.isEmpty ? PriceNotFound(text.trim()) : PriceChoices(matches);
      }
    });
    _touch();
  }

  void _pick(PriceProduct product) {
    _search.clear();
    setState(() => _result = PriceFound(product));
    _touch();
  }

  Future<void> _scanWithCamera() async {
    final code = await scanBarcodeOnce(context);
    if (code != null && mounted) await _onScan(code);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(priceCheckerControllerProvider(widget.storeId));
    final controller = ref.read(priceCheckerControllerProvider(widget.storeId).notifier);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final phone = MediaQuery.sizeOf(context).width < 600;
    final shown = _result is PriceFound ? (_result as PriceFound).product : null;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _touch(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  storeName: widget.storeName,
                  state: state,
                  now: now,
                  compact: phone,
                  onSync: state.syncing ? null : controller.sync,
                  onExit: () => showPriceCheckerExitDialog(context),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, phone ? 8 : 16, 16, 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: ScanSearchField(
                        controller: _search,
                        focusNode: _focus,
                        onScan: _onScan,
                        onChanged: _onChanged,
                        hintText: l10n.priceCheckerSearchHint,
                        onCameraScan: cameraScanAvailable ? _scanWithCamera : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Body(
                      state: state,
                      now: now,
                      result: _result,
                      storeId: widget.storeId,
                      onPick: _pick,
                    ),
                  ),
                ),
                _Footer(product: shown, state: state, now: now, compact: phone),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _statusText(AppLocalizations l10n, PriceCheckerState state, PriceCheckerStatus status) => switch (status) {
      PriceCheckerStatus.loading => l10n.priceCheckerLoading,
      PriceCheckerStatus.syncing => l10n.priceCheckerSyncing,
      PriceCheckerStatus.needsInitialSync => l10n.priceCheckerNeedsInitialSync,
      PriceCheckerStatus.offline => l10n.priceCheckerOffline,
      PriceCheckerStatus.failed => state.hasSnapshot ? l10n.priceCheckerSyncFailed : l10n.priceCheckerFirstSyncFailed,
      PriceCheckerStatus.current => l10n.priceCheckerSynced,
      PriceCheckerStatus.saved => l10n.priceCheckerSaved,
    };

class _Header extends StatelessWidget {
  const _Header({
    required this.storeName,
    required this.state,
    required this.now,
    required this.compact,
    required this.onSync,
    required this.onExit,
  });

  final String storeName;
  final PriceCheckerState state;
  final DateTime now;
  final bool compact;
  final VoidCallback? onSync;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = state.status(now);
    final problem = status == PriceCheckerStatus.failed || status == PriceCheckerStatus.needsInitialSync;
    final statusColor = problem
        ? scheme.error
        : status == PriceCheckerStatus.current
            ? scheme.primary
            : scheme.onSurfaceVariant;
    final statusIcon = switch (status) {
      PriceCheckerStatus.loading || PriceCheckerStatus.syncing => Icons.sync,
      PriceCheckerStatus.needsInitialSync || PriceCheckerStatus.offline => Icons.cloud_off_outlined,
      PriceCheckerStatus.failed => Icons.error_outline,
      PriceCheckerStatus.current => Icons.cloud_done_outlined,
      PriceCheckerStatus.saved => Icons.history,
    };

    return Material(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24, vertical: compact ? 8 : 14),
        child: Row(
          children: [
            UnoposLogo(size: compact ? 36 : 48),
            SizedBox(width: compact ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (compact ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)
                        ?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _statusText(l10n, state, status),
                          key: const ValueKey('price-checker-status'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ConnectionChip(online: state.online, compact: compact),
            IconButton(
              tooltip: l10n.priceCheckerSyncNow,
              onPressed: onSync,
              icon: state.syncing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: scheme.primary),
                    )
                  : const Icon(Icons.sync),
            ),
            // Deliberately small and quiet: for staff, not customers.
            IconButton(
              key: const ValueKey('price-checker-exit'),
              tooltip: l10n.priceCheckerExit,
              visualDensity: VisualDensity.compact,
              iconSize: 18,
              onPressed: onExit,
              icon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  const _ConnectionChip({required this.online, required this.compact});

  final bool online;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final fg = online ? scheme.onSecondaryContainer : scheme.onErrorContainer;
    final bg = online ? scheme.secondaryContainer : scheme.errorContainer;
    final label = online ? l10n.priceCheckerOnline : l10n.priceCheckerOfflineShort;
    return Tooltip(
      message: label,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(online ? Icons.wifi : Icons.wifi_off, size: 16, color: fg),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.now,
    required this.result,
    required this.storeId,
    required this.onPick,
  });

  final PriceCheckerState state;
  final DateTime now;
  final PriceLookup? result;
  final String storeId;
  final ValueChanged<PriceProduct> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = state.status(now);
    if (!state.hasSnapshot) {
      final waiting = status == PriceCheckerStatus.loading || status == PriceCheckerStatus.syncing;
      return _Message(
        icon: waiting ? null : Icons.cloud_download_outlined,
        title: _statusText(l10n, state, status),
        error: !waiting,
      );
    }
    return switch (result) {
      null => _Message(icon: Icons.qr_code_scanner, title: l10n.priceCheckerIdle, subtitle: l10n.priceCheckerIdleHint),
      PriceNotFound(:final query) => _Message(icon: Icons.search_off, title: l10n.priceCheckerNotFound(query)),
      PriceFound(:final product) =>
        _ProductView(product: product, storeId: storeId, imagesVersion: state.imagesVersion),
      PriceChoices(:final products, :final exact) => _ChoiceList(
          products: products,
          title: exact ? l10n.priceCheckerDuplicateCode : l10n.priceCheckerChoose,
          storeId: storeId,
          imagesVersion: state.imagesVersion,
          onPick: onPick,
        ),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.subtitle, this.error = false});

  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon == null)
                const CircularProgressIndicator()
              else
                Icon(icon, size: 88, color: error ? scheme.error : scheme.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  const _ProductView({required this.product, required this.storeId, required this.imagesVersion});

  final PriceProduct product;
  final String storeId;
  final int imagesVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 700;
      final imageSize = wide ? 240.0 : (constraints.maxWidth * 0.42).clamp(96.0, 180.0);

      final details = Column(
        crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            product.name,
            key: const ValueKey('price-checker-name'),
            textAlign: wide ? TextAlign.start : TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: (wide ? theme.textTheme.headlineMedium : theme.textTheme.headlineSmall)
                ?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
          ),
          if (product.categoryName != null && product.categoryName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(product.categoryName!, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 16),
          // The theme's container colour and its "on" colour are made to be
          // read together, so the price keeps its contrast in every theme.
          Container(
            padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 20, vertical: wide ? 16 : 12),
            decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Money.format(product.sellPriceMinorUnits),
                key: const ValueKey('price-checker-price'),
                style: (wide ? theme.textTheme.displayLarge : theme.textTheme.displaySmall)
                    ?.copyWith(fontWeight: FontWeight.w800, color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.priceCheckerPerUnit(productUnitLabel(context, product.unit)),
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (product.wholesalePriceMinorUnits != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.priceCheckerWholesale(Money.format(product.wholesalePriceMinorUnits!)),
              style: theme.textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      );

      final image = _SnapshotImage(
        storeId: storeId,
        imagePath: product.imagePath,
        size: imageSize,
        imagesVersion: imagesVersion,
      );

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: wide
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [image, const SizedBox(width: 40), Flexible(child: details)],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [image, const SizedBox(height: 16), details],
                  ),
          ),
        ),
      );
    });
  }
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({
    required this.products,
    required this.title,
    required this.storeId,
    required this.imagesVersion,
    required this.onPick,
  });

  final List<PriceProduct> products;
  final String title;
  final String storeId;
  final int imagesVersion;
  final ValueChanged<PriceProduct> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return Material(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      leading: _SnapshotImage(
                          storeId: storeId, imagePath: p.imagePath, size: 44, imagesVersion: imagesVersion),
                      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(p.serial, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text(
                        Money.format(p.sellPriceMinorUnits),
                        style:
                            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: scheme.primary),
                      ),
                      onTap: () => onPick(p),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A product photo from the price checker's own saved copies (never the
/// network), or a placeholder.
class _SnapshotImage extends ConsumerStatefulWidget {
  const _SnapshotImage({
    required this.storeId,
    required this.imagePath,
    required this.size,
    required this.imagesVersion,
  });

  final String storeId;
  final String? imagePath;
  final double size;
  final int imagesVersion;

  @override
  ConsumerState<_SnapshotImage> createState() => _SnapshotImageState();
}

class _SnapshotImageState extends ConsumerState<_SnapshotImage> {
  Future<Uint8List?>? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SnapshotImage old) {
    super.didUpdateWidget(old);
    if (old.imagePath != widget.imagePath || old.imagesVersion != widget.imagesVersion) _load();
  }

  void _load() {
    final path = widget.imagePath;
    _bytes =
        (path == null || path.isEmpty) ? null : ref.read(priceSnapshotStoreProvider).loadImage(widget.storeId, path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(widget.size * 0.12);
    final placeholder = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: radius),
      child: Icon(Icons.inventory_2_outlined, size: widget.size * 0.45, color: scheme.onSurfaceVariant),
    );
    final future = _bytes;
    if (future == null) return placeholder;
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes == null) return placeholder;
        return ClipRRect(
          borderRadius: radius,
          child: Image.memory(
            bytes,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => placeholder,
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.product, required this.state, required this.now, required this.compact});

  final PriceProduct? product;
  final PriceCheckerState state;
  final DateTime now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final snapshot = state.snapshot;
    final lastSync = state.meta.lastSuccessfulSync;
    final current = state.isCurrent(now);

    final serial = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          priceCheckerSerialLabel,
          style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 0.4),
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: product?.serial ?? '—',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: scheme.onSurface),
            ),
            if (product != null)
              TextSpan(
                text: '  ${product!.serialIsBarcode ? l10n.priceCheckerBarcode : l10n.priceCheckerSku}',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ]),
          key: const ValueKey('price-checker-serial'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final infoStyle = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    final info = Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (snapshot != null) ...[
          Text(l10n.priceCheckerLastSnapshot(AppDateFormat.dateTime(snapshot.createdAt)), style: infoStyle),
          Text(l10n.priceCheckerVersion(snapshot.version, snapshot.productCount), style: infoStyle),
        ],
        Text(
          lastSync == null ? l10n.priceCheckerNeverSynced : l10n.priceCheckerLastSync(AppDateFormat.dateTime(lastSync)),
          style: infoStyle,
        ),
        if (snapshot != null)
          Text(
            current ? l10n.priceCheckerLatest : l10n.priceCheckerOlder,
            key: const ValueKey('price-checker-freshness'),
            style: infoStyle?.copyWith(
              fontWeight: FontWeight.w600,
              color: current ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    return Material(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 8 : 12),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [serial, const SizedBox(height: 6), info],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [Expanded(child: serial), const SizedBox(width: 16), info],
              ),
      ),
    );
  }
}
