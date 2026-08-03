import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../domain/auth_models.dart';
import '../domain/session_controller.dart';

class TilePickerScreen extends ConsumerWidget {
  const TilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final store = ref.watch(sessionControllerProvider).store;
    final employeesAsync = store == null
        ? const AsyncValue<List<EmployeeRecord>>.data([])
        : ref.watch(_employeesStreamProvider(store.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickAccountTitle)),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // TODO(debug): shows the raw stream error instead of a generic
        // message while diagnosing the Supabase onboarding flow — revert to
        // l10n.errorGeneric once this is confirmed working end to end
        // against a real project.
        error: (e, st) => Center(child: Text('${l10n.errorGeneric}\n$e')),
        data: (employees) {
          if (employees.isEmpty) {
            return Center(child: Text('${l10n.errorGeneric}\n(no employees found for this store)'));
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: GridView.builder(
                padding: const EdgeInsets.all(32),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemCount: employees.length,
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return _EmployeeTile(
                    employee: employee,
                    onTap: () {
                      ref.read(selectedEmployeeForPinProvider.notifier).state = employee;
                      context.go(RoutePaths.pinPad);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

final _employeesStreamProvider =
    StreamProvider.family<List<EmployeeRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).watchEmployees(storeId);
});

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final EmployeeRecord employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(employee.avatarColorHex.replaceFirst('#', '0xFF')));
    final initials = employee.name.trim().isEmpty
        ? '?'
        : employee.name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 36, backgroundColor: color, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Text(employee.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(employee.role.name, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
