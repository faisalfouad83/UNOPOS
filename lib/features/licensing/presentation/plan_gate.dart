import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../domain/entitlement.dart';
import '../domain/license_watch.dart';

/// Shows [child] when the store's plan includes the section at [path];
/// otherwise a page saying the section isn't in the plan. Sections stay
/// open while the plan isn't known (first start offline, local build).
class PlanGate extends ConsumerWidget {
  const PlanGate({super.key, required this.path, required this.child});

  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider);
    if (entitlement == null || entitlement.allowsPath(path)) return child;
    return NotInPlanView(entitlement: entitlement);
  }
}

/// "This section is not in your plan", with the plan's name and a way back.
class NotInPlanView extends StatelessWidget {
  const NotInPlanView({super.key, required this.entitlement});

  final Entitlement entitlement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.planNotInPlanTitle, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l10n.planNotInPlanBody(entitlement.planName),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                onPressed: () => context.go(RoutePaths.home),
                icon: const Icon(Icons.home_outlined),
                label: Text(l10n.planBackHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
