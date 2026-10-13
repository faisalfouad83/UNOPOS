import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_credits.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/support_models.dart';
import 'support_chat.dart';

String conversationStatusLabel(AppLocalizations l10n, ConversationStatus s) => switch (s) {
      ConversationStatus.open => l10n.supportStatusOpen,
      ConversationStatus.pending => l10n.supportStatusPending,
      ConversationStatus.closed => l10n.supportStatusClosed,
    };

/// The support team's portal: every store's conversation (search, filter),
/// the store's details, and the full shared history to read and answer.
/// Any support employee can pick up any conversation; replies are signed
/// with their name. Presence is reported every minute.
class SupportPortalScreen extends ConsumerStatefulWidget {
  const SupportPortalScreen({super.key});

  @override
  ConsumerState<SupportPortalScreen> createState() => _SupportPortalScreenState();
}

class _SupportPortalScreenState extends ConsumerState<SupportPortalScreen> {
  final _search = TextEditingController();
  ConversationStatus? _status;
  List<SupportInboxEntry> _inbox = const [];
  bool _loading = true;
  Object? _error;
  String? _selectedId;
  bool _onBreak = false;
  Timer? _heartbeat;
  Timer? _debounce;
  StreamSubscription<void>? _changes;

  @override
  void initState() {
    super.initState();
    _beat();
    _heartbeat = Timer.periodic(const Duration(seconds: 50), (_) => _beat());
    _reload();
    _changes = ref.read(supportRepositoryProvider)!.watchConversationChanges().listen(
          (_) => _scheduleReload(),
          onError: (Object _) {},
        );
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    _debounce?.cancel();
    _changes?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _beat() async {
    try {
      await ref.read(supportRepositoryProvider)!.heartbeat(_onBreak ? 'break' : 'online');
    } catch (_) {}
  }

  void _scheduleReload() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reload);
  }

  Future<void> _reload() async {
    try {
      final rows = await ref.read(supportRepositoryProvider)!.inbox(search: _search.text.trim(), status: _status);
      if (!mounted) return;
      setState(() {
        _inbox = rows;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final agent = ref.watch(sessionControllerProvider).supportAgent;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final selected = _inbox.where((e) => e.conversationId == _selectedId).firstOrNull;

    final list = _InboxList(
      entries: _inbox,
      loading: _loading,
      error: _error,
      selectedId: _selectedId,
      search: _search,
      status: _status,
      onSearch: _scheduleReload,
      onStatus: (s) {
        setState(() => _status = s);
        _reload();
      },
      onRetry: _reload,
      onOpen: (e) => setState(() => _selectedId = e.conversationId),
    );
    final detail = selected == null
        ? Center(child: Text(l10n.supportPickConversation))
        : _ConversationPane(
            key: ValueKey(selected.conversationId),
            entry: selected,
            myAgentId: agent?.id,
            onChanged: _reload,
            onBack: wide ? null : () => setState(() => _selectedId = null),
          );

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.support_agent)),
        title: Text('${l10n.supportPortalTitle} · ${agent?.fullName ?? ''}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                    value: false,
                    label: Text(l10n.supportPresenceOnline),
                    icon: const Icon(Icons.circle, size: 12, color: Colors.green)),
                ButtonSegment(
                    value: true,
                    label: Text(l10n.supportPresenceBreak),
                    icon: const Icon(Icons.free_breakfast_outlined, size: 16)),
              ],
              selected: {_onBreak},
              onSelectionChanged: (s) {
                setState(() => _onBreak = s.first);
                _beat();
              },
            ),
          ),
          IconButton(tooltip: l10n.actionRefresh, icon: const Icon(Icons.refresh), onPressed: _reload),
          IconButton(
            tooltip: l10n.actionSignOut,
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).signOutSupport();
              if (context.mounted) context.go(RoutePaths.activation);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: wide
                ? Row(
                    children: [
                      SizedBox(width: 380, child: list),
                      const VerticalDivider(width: 1),
                      Expanded(child: detail),
                    ],
                  )
                : (selected == null ? list : detail),
          ),
          const Padding(padding: EdgeInsets.all(2), child: AppCredits(alignment: AlignmentDirectional.centerEnd)),
        ],
      ),
    );
  }
}

class _InboxList extends StatelessWidget {
  const _InboxList({
    required this.entries,
    required this.loading,
    required this.error,
    required this.selectedId,
    required this.search,
    required this.status,
    required this.onSearch,
    required this.onStatus,
    required this.onRetry,
    required this.onOpen,
  });

  final List<SupportInboxEntry> entries;
  final bool loading;
  final Object? error;
  final String? selectedId;
  final TextEditingController search;
  final ConversationStatus? status;
  final VoidCallback onSearch;
  final ValueChanged<ConversationStatus?> onStatus;
  final VoidCallback onRetry;
  final ValueChanged<SupportInboxEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.supportSearchHint),
            onChanged: (_) => onSearch(),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final s in <ConversationStatus?>[null, ...ConversationStatus.values])
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    label: Text(s == null ? l10n.invoiceAnyStatus : conversationStatusLabel(l10n, s)),
                    selected: status == s,
                    onSelected: (_) => onStatus(s),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null && entries.isEmpty
                  ? Center(
                      child: TextButton.icon(
                          onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
                    )
                  : entries.isEmpty
                      ? Center(child: Text(l10n.supportNoConversations))
                      : ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final e = entries[i];
                            return ListTile(
                              selected: e.conversationId == selectedId,
                              leading: Badge(
                                isLabelVisible: e.unread > 0,
                                label: Text('${e.unread}'),
                                child:
                                    CircleAvatar(child: Text(e.storeName.isEmpty ? '?' : e.storeName[0].toUpperCase())),
                              ),
                              title: Text('${e.storeName} · ${e.storeLoginId}', overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                '${conversationStatusLabel(l10n, e.status)}'
                                '${e.assignedAgentName == null ? '' : ' · ${e.assignedAgentName}'}\n${e.lastMessagePreview}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              isThreeLine: true,
                              trailing:
                                  Text(AppDateFormat.shortDate(e.lastMessageAt), style: theme.textTheme.labelSmall),
                              onTap: () => onOpen(e),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _ConversationPane extends ConsumerWidget {
  const _ConversationPane(
      {super.key, required this.entry, required this.myAgentId, required this.onChanged, this.onBack});

  final SupportInboxEntry entry;
  final String? myAgentId;
  final VoidCallback onChanged;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.watch(supportRepositoryProvider)!;
    final mine = entry.assignedAgentId != null && entry.assignedAgentId == myAgentId;

    Future<void> update({bool takeOver = false, ConversationStatus? status}) async {
      try {
        await repo.updateConversation(entry.conversationId, takeOver: takeOver, status: status);
        onChanged();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onBack != null) IconButton(icon: const BackButtonIcon(), onPressed: onBack),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.storeName, style: theme.textTheme.titleMedium),
                      SelectableText(
                        [
                          '${l10n.supportStoreId}: ${entry.storeLoginId}',
                          if (entry.ownerName.isNotEmpty) entry.ownerName,
                          if (entry.phone.isNotEmpty) entry.phone,
                          if (entry.address.isNotEmpty) entry.address,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        [
                          '${l10n.supportActivation}: ${entry.activationStatus}'
                              '${entry.expiresAt == null ? '' : ' (${AppDateFormat.shortDate(entry.expiresAt!)})'}',
                          '${l10n.supportOpened}: ${AppDateFormat.dateTime(entry.createdAt)}',
                          '${l10n.supportLastMessage}: ${AppDateFormat.dateTime(entry.lastMessageAt)}',
                          '${l10n.supportAssigned}: ${entry.assignedAgentName ?? '—'}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!mine)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.pan_tool_alt_outlined),
                        label: Text(entry.assignedAgentId == null ? l10n.supportTake : l10n.supportTakeOver),
                        onPressed: () => update(takeOver: true),
                      ),
                    DropdownButton<ConversationStatus>(
                      value: entry.status,
                      items: [
                        for (final s in ConversationStatus.values)
                          DropdownMenuItem(value: s, child: Text(conversationStatusLabel(l10n, s))),
                      ],
                      onChanged: (s) => s == null ? null : update(status: s),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SupportChat(
            conversationId: entry.conversationId,
            agentView: true,
            send: (body, clientId, internal) async {
              await repo.agentSend(entry.conversationId, body, clientId, internal: internal);
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}
