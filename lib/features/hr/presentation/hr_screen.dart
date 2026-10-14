import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/data/device_lock.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/domain/account_rules.dart';
import '../../auth/presentation/confirm_with_pin.dart';
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
    final me = ref.watch(sessionControllerProvider).employee;
    final held = ref.watch(heldDevicesProvider(storeId)).valueOrNull ?? const {};

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
                  [
                    '$roleLabel · ${employee.phone} · ${l10n.hrSalary}: ${Money.format(employee.salaryMinorUnits)}',
                    if (held[employee.id] case final device?) l10n.hrOpenOnDevice(device.isEmpty ? '—' : device),
                  ].join('\n'),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (held.containsKey(employee.id) && me != null && me.role.isStoreAdmin)
                      IconButton(
                        icon: const Icon(Icons.phonelink_erase_outlined),
                        tooltip: l10n.hrReleaseDevice,
                        onPressed: () => _releaseDevice(context, ref, me, employee),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showEmployeeEditDialog(context, ref, existing: employee),
                    ),
                    // Only offered when allowed: never the owner, a manager
                    // only to the owner, nobody to themselves (and the
                    // server checks the same with the actor's PIN).
                    if (me != null && canDeactivate(me, employee) == null)
                      IconButton(
                        icon: const Icon(Icons.person_off_outlined),
                        tooltip: context.l10n.hrDeactivate,
                        onPressed: () => _deactivate(context, ref, me, employee),
                      )
                    else if (employee.role.name == 'owner')
                      Tooltip(
                        message: l10n.accountOwnerProtected,
                        child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.shield_outlined)),
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

/// Deactivates [employee] after the signed-in account confirms with its PIN.
/// The account's history (sales, shifts) stays; it just can't sign in.
Future<void> _deactivate(BuildContext context, WidgetRef ref, EmployeeRecord me, EmployeeRecord employee) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final pin = await confirmWithPin(
    context,
    title: '${context.l10n.hrDeactivate}: ${employee.name}',
    message: l10n.accountDeactivateConfirm(employee.name),
  );
  if (pin == null) return;
  try {
    await ref.read(authRepositoryProvider).deactivateEmployee(employeeId: employee.id, actorId: me.id, actorPin: pin);
    messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeactivated(employee.name))));
  } on AccountChangeException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(accountRefusalMessage(l10n, e))));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
  }
}

/// Frees a cashier account left open on another device, after the owner or
/// a manager confirms with their PIN.
Future<void> _releaseDevice(BuildContext context, WidgetRef ref, EmployeeRecord me, EmployeeRecord employee) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final lock = ref.read(deviceLockProvider);
  if (lock == null) return;
  final pin = await confirmWithPin(
    context,
    title: '${l10n.hrReleaseDevice}: ${employee.name}',
    message: l10n.hrReleaseDeviceConfirm(employee.name),
  );
  if (pin == null) return;
  try {
    await lock.forceRelease(employeeId: employee.id, actorId: me.id, actorPin: pin);
    messenger.showSnackBar(SnackBar(content: Text(l10n.hrDeviceReleased(employee.name))));
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('$e'.contains('wrong PIN') ? l10n.pinPadIncorrect : l10n.errorGeneric)),
    );
  }
}
