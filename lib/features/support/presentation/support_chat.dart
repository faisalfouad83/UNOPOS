import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/support_models.dart';

/// The support number, always visible at the top of a support chat; tapping
/// it opens the phone app where there is one.
class SupportPhoneBanner extends StatelessWidget {
  const SupportPhoneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      child: InkWell(
        onTap: () => launchUrl(Uri(scheme: 'tel', path: supportPhoneNumber)),
        onLongPress: () {
          Clipboard.setData(const ClipboardData(text: supportPhoneNumber));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.supportPhoneCopied)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.phone_in_talk, color: scheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.supportPhoneLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
              Text(
                supportPhoneNumber,
                textDirection: TextDirection.ltr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SendSupportMessage = Future<void> Function(String body, String clientMessageId, bool internal);

/// A conversation's full history (live from the server, which is the only
/// record) and a box to write in. [agentView]: the support team's side —
/// their own messages on the right, each signed with the employee's name,
/// and internal notes the store never sees.
class SupportChat extends ConsumerStatefulWidget {
  const SupportChat({super.key, required this.conversationId, required this.send, this.agentView = false});

  final String conversationId;
  final SendSupportMessage send;
  final bool agentView;

  @override
  ConsumerState<SupportChat> createState() => _SupportChatState();
}

class _SupportChatState extends ConsumerState<SupportChat> {
  final _input = TextEditingController();
  final _outgoing = <OutgoingMessage>[];
  bool _internal = false;
  late Stream<List<SupportMessageRecord>> _stream = _subscribe();

  Stream<List<SupportMessageRecord>> _subscribe() =>
      ref.read(supportRepositoryProvider)!.watchMessages(widget.conversationId);

  @override
  void didUpdateWidget(SupportChat old) {
    super.didUpdateWidget(old);
    if (old.conversationId != widget.conversationId) {
      _stream = _subscribe();
      _outgoing.clear();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _deliver(OutgoingMessage m) async {
    try {
      await widget.send(m.body, m.clientMessageId, m.internal);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final i = _outgoing.indexWhere((o) => o.clientMessageId == m.clientMessageId);
        if (i >= 0) _outgoing[i] = m.asFailed();
      });
    }
  }

  void _send() {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    // The id is fixed now: a retry re-sends the same message, never a copy.
    final m =
        OutgoingMessage(clientMessageId: IdGenerator.newId(), body: body, internal: widget.agentView && _internal);
    setState(() {
      _outgoing.add(m);
      _input.clear();
    });
    _deliver(m);
  }

  void _retry(OutgoingMessage m) {
    setState(() {
      final i = _outgoing.indexWhere((o) => o.clientMessageId == m.clientMessageId);
      if (i >= 0) _outgoing[i] = m.asSending();
    });
    _deliver(m);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<SupportMessageRecord>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.hasError && !snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.errorGeneric),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.actionRetry),
                        onPressed: () => setState(() => _stream = _subscribe()),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = mergeMessages(snapshot.data!, _outgoing);
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      widget.agentView ? l10n.supportNoMessages : l10n.supportStartHint,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              // Newest at the bottom, kept in view as messages arrive.
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[items.length - 1 - i];
                  if (item is SupportMessageRecord) {
                    final mine = widget.agentView ? !item.fromStore : item.fromStore;
                    return _Bubble(
                      body: item.body,
                      mine: mine,
                      note: item.isInternalNote,
                      sender: item.fromStore
                          ? (widget.agentView ? item.senderName : l10n.supportYou)
                          : (item.senderName.isEmpty ? l10n.supportTeam : item.senderName),
                      time: AppDateFormat.dateTime(item.createdAt),
                    );
                  }
                  final o = item as OutgoingMessage;
                  return _Bubble(
                    body: o.body,
                    mine: true,
                    note: o.internal,
                    sender: l10n.supportYou,
                    time: o.failed ? l10n.supportNotSent : l10n.supportSending,
                    failed: o.failed,
                    onRetry: o.failed ? () => _retry(o) : null,
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.agentView)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilterChip(
                      avatar: const Icon(Icons.lock_outline, size: 16),
                      label: Text(l10n.supportInternalNote),
                      selected: _internal,
                      onSelected: (v) => setState(() => _internal = v),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.enter, control: true): _send,
                        },
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 4000,
                          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                          decoration: InputDecoration(
                            hintText: _internal ? l10n.supportNoteHint : l10n.supportMessageHint,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: l10n.supportSend,
                      icon: const Icon(Icons.send),
                      onPressed: _send,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.body,
    required this.mine,
    required this.sender,
    required this.time,
    this.note = false,
    this.failed = false,
    this.onRetry,
  });

  final String body;
  final bool mine;
  final String sender;
  final String time;
  final bool note;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = note
        ? Colors.amber.withValues(alpha: 0.25)
        : mine
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest;
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: failed ? Border.all(color: scheme.error) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (note)
                        Text(l10n.supportInternalNote,
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                      SelectableText(body),
                    ],
                  ),
                ),
              ),
              // The writer's name under every message.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  failed ? '$sender · $time · ${l10n.supportTapToRetry}' : '$sender · $time',
                  style: theme.textTheme.labelSmall?.copyWith(color: failed ? scheme.error : scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
