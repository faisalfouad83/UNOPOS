import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';

Future<void> showAddSupplierDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final personController = TextEditingController();
  final addressController = TextEditingController();
  var saving = false;
  String? nameError;
  String? error;

  String? optional(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.suppliersAddSupplier),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.commonName, errorText: nameError),
                  onChanged: (_) => setState(() => nameError = null),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.commonPhone),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: personController,
                  decoration: InputDecoration(labelText: context.l10n.supplierContactPerson),
                ),
                const SizedBox(height: 12),
                TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.commonAddress)),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (nameController.text.trim().isEmpty) {
                      setState(() => nameError = l10n.errorRequired);
                      return;
                    }
                    setState(() {
                      saving = true;
                      error = null;
                    });
                    try {
                      await ref.read(suppliersRepositoryProvider).createSupplier(
                            storeId: session.store!.id,
                            name: nameController.text.trim(),
                            contactPhone: optional(phoneController),
                            contactPerson: optional(personController),
                            address: optional(addressController),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (_) {
                      if (!context.mounted) return;
                      setState(() {
                        saving = false;
                        error = l10n.errorGeneric;
                      });
                    }
                  },
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    ),
  );
}
