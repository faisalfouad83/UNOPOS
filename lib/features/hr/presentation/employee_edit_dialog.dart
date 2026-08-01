import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/magic_passcodes.dart';
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
                  onChanged: (v) => setState(() => role = v ?? role),
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
                    labelText: existing == null ? 'Passcode (4 digits)' : 'Reset passcode (leave blank to keep)',
                    errorText: error,
                  ),
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
              if (existing == null) {
                await repo.createEmployee(
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
