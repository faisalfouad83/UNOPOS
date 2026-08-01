import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';
import 'employee_edit_dialog.dart';

final _employeesProvider = StreamProvider.autoDispose.family<List<EmployeeRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).watchEmployees(storeId);
});

/// Full staff directory with salary/allowances — visible only to
/// Owner/Manager/Developer per the route guard. Never reachable by a
/// Cashier or Warehouse Manager.
class HrScreen extends ConsumerWidget {
  const HrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final employeesAsync = ref.watch(_employeesProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hrTitle)),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (employees) {
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final roleLabel = switch (employee.role.name) {
                'owner' => l10n.hrRoleOwner,
                'manager' => l10n.hrRoleManager,
                'cashier' => l10n.hrRoleCashier,
                _ => l10n.hrRoleWarehouseManager,
              };
              return ListTile(
                leading: CircleAvatar(child: Text(employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?')),
                title: Text(employee.name),
                subtitle: Text(
                  '$roleLabel · ${employee.phone} · ${l10n.hrSalary}: ${Money.format(employee.salaryMinorUnits, currencySymbol: r'$')}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showEmployeeEditDialog(context, ref, existing: employee),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_off_outlined),
                      tooltip: 'Deactivate',
                      onPressed: () => ref.read(authRepositoryProvider).setEmployeeActive(employee.id, false),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showEmployeeEditDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.hrAddEmployee),
      ),
    );
  }
}
