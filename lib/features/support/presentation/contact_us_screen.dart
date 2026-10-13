import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import 'support_chat.dart';

final _myConversationProvider = FutureProvider.autoDispose.family<String, String>((ref, storeId) async {
  final repo = ref.watch(supportRepositoryProvider)!;
  final id = await repo.myConversationId();
  await repo.storeMarkRead();
  return id;
});

/// Unread support replies for the signed-in store (badge on Contact Us).
final storeSupportUnreadProvider = StreamProvider.autoDispose.family<int, String>((ref, storeId) {
  final repo = ref.watch(supportRepositoryProvider);
  if (repo == null) return Stream.value(0);
  return repo.watchStoreUnread(storeId);
});

/// Opens Contact Us: the store's own, lasting conversation with support,
/// the support number on top. Without a signed-in store (sign-in screen)
/// it shows the number and how to chat.
Future<void> openContactUs(BuildContext context, WidgetRef ref) async {
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null || ref.read(supportRepositoryProvider) == null) {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.support_agent),
        title: Text(l10n.contactUs),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SupportPhoneBanner(),
            const SizedBox(height: 12),
            Text(l10n.contactUsSignInToChat, textAlign: TextAlign.center),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose))],
      ),
    );
    return;
  }
  await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ContactUsScreen(storeId: storeId)));
}

class ContactUsScreen extends ConsumerWidget {
  const ContactUsScreen({super.key, required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final conversation = ref.watch(_myConversationProvider(storeId));
    // Signed out or switched store meanwhile: this chat belongs to the old one.
    final current = ref.watch(sessionControllerProvider).store?.id;
    if (current != storeId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactUs)),
      body: Column(
        children: [
          // Stays on top while the messages scroll underneath.
          const SupportPhoneBanner(),
          Expanded(
            child: conversation.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.supportOffline, textAlign: TextAlign.center),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.actionRetry),
                      onPressed: () => ref.invalidate(_myConversationProvider(storeId)),
                    ),
                  ],
                ),
              ),
              data: (conversationId) => SupportChat(
                conversationId: conversationId,
                send: (body, clientId, _) => ref.read(supportRepositoryProvider)!.storeSend(body, clientId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Contact Us button for the top bar and Settings, with unread badge.
class ContactUsButton extends ConsumerWidget {
  const ContactUsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    final unread = storeId == null ? 0 : ref.watch(storeSupportUnreadProvider(storeId)).valueOrNull ?? 0;
    return IconButton(
      tooltip: l10n.contactUs,
      icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.support_agent)),
      onPressed: () => openContactUs(context, ref),
    );
  }
}
