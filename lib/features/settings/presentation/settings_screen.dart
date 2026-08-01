import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import 'activation_settings_section.dart';
import 'backup_settings_section.dart';
import 'factory_reset_section.dart';
import 'general_settings_section.dart';
import 'printer_settings_section.dart';

final _settingsStreamProvider = StreamProvider.autoDispose.family((ref, String storeId) {
  return ref.watch(settingsRepositoryProvider).watchSettings(storeId);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final settingsAsync = ref.watch(_settingsStreamProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GeneralSettingsSection(storeId: storeId, settings: settings),
              const SizedBox(height: 16),
              PrinterSettingsSection(settings: settings),
              const SizedBox(height: 16),
              ActivationSettingsSection(storeId: storeId),
              const SizedBox(height: 16),
              BackupSettingsSection(storeId: storeId, settings: settings),
              const SizedBox(height: 16),
              const FactoryResetSection(),
            ],
          );
        },
      ),
    );
  }
}
