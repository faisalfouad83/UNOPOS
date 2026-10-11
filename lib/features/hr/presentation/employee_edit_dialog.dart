import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/constants/permissions.dart';
import '../../../core/constants/roles.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';

Future<void> showEmployeeEditDialog(BuildContext context, WidgetRef ref, {EmployeeRecord? existing}) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final nameController = TextEditingController(text: existing?.name);
  final phoneController = TextEditingController(text: existing?.phone);
  final addressController = TextEditingController(text: existing?.address);
  final salaryController = TextEditingController(
    text: existing == null ? '' : Money.toMajorUnits(existing.salaryMinorUnits).toStringAsFixed(2),
  );
  final allowancesController = TextEditingController(
    text: existing == null ? '' : Money.toMajorUnits(existing.allowancesMinorUnits).toStringAsFixed(2),
  );
  final pinController = TextEditingController();
  StoreRole role = existing?.role ?? StoreRole.cashier;
  String? error;
  var permissions = {...(existing?.permissions ?? defaultPermissionsFor(role))};
  // Until the permissions are touched, changing the role resets them to
  // that role's defaults.
  var permissionsEdited = existing?.customPermissions != null;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? l10n.hrAddEmployee : existing.name),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.commonName)),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: InputDecoration(labelText: l10n.commonPhone)),
                const SizedBox(height: 12),
                TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.commonAddress)),
                const SizedBox(height: 12),
                DropdownButtonFormField<StoreRole>(
                  initialValue: role,
                  decoration: InputDecoration(labelText: l10n.hrRole),
                  items: [
                    DropdownMenuItem(value: StoreRole.owner, child: Text(l10n.hrRoleOwner)),
                    DropdownMenuItem(value: StoreRole.manager, child: Text(l10n.hrRoleManager)),
                    DropdownMenuItem(value: StoreRole.cashier, child: Text(l10n.hrRoleCashier)),
                    DropdownMenuItem(value: StoreRole.warehouseManager, child: Text(l10n.hrRoleWarehouseManager)),
                  ],
                  onChanged: (v) => setState(() {
                    role = v ?? role;
                    if (!permissionsEdited) permissions = {...defaultPermissionsFor(role)};
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: salaryController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: InputDecoration(labelText: l10n.hrSalary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: allowancesController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                        decoration: InputDecoration(labelText: l10n.hrAllowances),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: InputDecoration(
                    labelText: existing == null ? l10n.hrPasscodeNew : l10n.hrPasscodeReset,
                    errorText: error,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(l10n.permissionsTitle, style: Theme.of(context).textTheme.titleSmall),
                ),
                if (role == StoreRole.owner)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(l10n.permissionsOwnerAll, style: Theme.of(context).textTheme.bodySmall),
                  )
                else
                  for (final permission in AppPermission.values)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(permissionLabel(l10n, permission)),
                      value: permissions.contains(permission),
                      onChanged: (on) => setState(() {
                        permissionsEdited = true;
                        on == true ? permissions.add(permission) : permissions.remove(permission);
                      }),
                    ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () async {
              if (pinController.text.isNotEmpty && MagicPasscodes.isReserved(pinController.text)) {
                setState(() => error = l10n.errorRequired);
                return;
              }
              if (existing == null && pinController.text.length != 4) {
                setState(() => error = l10n.errorRequired);
                return;
              }

              final repo = ref.read(authRepositoryProvider);
              final custom = role == StoreRole.owner || _sameSet(permissions, defaultPermissionsFor(role))
                  ? null
                  : permissions;
              if (existing == null) {
                final created = await repo.createEmployee(
                  storeId: session.store!.id,
                  branchId: session.currentBranchId,
                  name: nameController.text.trim(),
                  role: role.name,
                  pin: pinController.text,
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  salaryMinorUnits: Money.toMinorUnits(double.tryParse(salaryController.text) ?? 0),
                  allowancesMinorUnits: Money.toMinorUnits(double.tryParse(allowancesController.text) ?? 0),
                );
                if (custom != null) await repo.updateEmployee(created.copyWith(customPermissions: custom));
              } else {
                await repo.updateEmployee(
                  EmployeeRecord(
                    id: existing.id,
                    storeId: existing.storeId,
                    branchId: existing.branchId,
                    name: nameController.text.trim(),
                    role: role,
                    pinHash: existing.pinHash,
                    phone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                    salaryMinorUnits: Money.toMinorUnits(double.tryParse(salaryController.text) ?? 0),
                    allowancesMinorUnits: Money.toMinorUnits(double.tryParse(allowancesController.text) ?? 0),
                    avatarColorHex: existing.avatarColorHex,
                    isActive: existing.isActive,
                    customPermissions: custom,
                  ),
                  newPin: pinController.text.isEmpty ? null : pinController.text,
                );
              }
              await ref.read(auditRepositoryProvider).log(
                    storeId: session.store!.id,
                    userId: session.employee?.id ?? session.store!.id,
                    action: existing == null ? 'employee_created' : 'employee_updated',
                    entityType: 'employee',
                    entityId: existing?.id,
                    afterValueJson: nameController.text.trim(),
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}

bool _sameSet(Set<AppPermission> a, Set<AppPermission> b) => a.length == b.length && a.containsAll(b);

String permissionLabel(AppLocalizations l10n, AppPermission permission) => switch (permission) {
      AppPermission.sell => l10n.permissionSell,
      AppPermission.giveDiscount => l10n.permissionGiveDiscount,
      AppPermission.processReturns => l10n.permissionProcessReturns,
      AppPermission.debts => l10n.permissionDebts,
      AppPermission.customers => l10n.permissionCustomers,
      AppPermission.inventory => l10n.permissionInventory,
      AppPermission.editProducts => l10n.permissionEditProducts,
      AppPermission.suppliers => l10n.permissionSuppliers,
      AppPermission.expenses => l10n.permissionExpenses,
      AppPermission.accounting => l10n.permissionAccounting,
      AppPermission.reports => l10n.permissionReports,
      AppPermission.hr => l10n.permissionHr,
      AppPermission.settings => l10n.permissionSettings,
    };
