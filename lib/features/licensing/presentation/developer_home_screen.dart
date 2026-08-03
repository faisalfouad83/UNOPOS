import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../auth/domain/session_controller.dart';
import '../../developer/presentation/developer_console_screen.dart';
import 'license_console.dart';

/// On the local Drift build this is just the license generator (there's no
/// concept of "other stores" to manage from a single install). On the
/// shared Supabase backend it's the full multi-tab Developer Console —
/// dashboard, store management, licenses, notifications.
class DeveloperHomeScreen extends ConsumerWidget {
  const DeveloperHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.developerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.actionSignOut,
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).signOutDeveloper();
              if (context.mounted) context.go(RoutePaths.activation);
            },
          ),
        ],
      ),
      body: kUseSupabaseBackend ? const DeveloperConsoleScreen() : const LicenseConsole(),
    );
  }
}
