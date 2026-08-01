import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.suppliersAddSupplier),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.commonName)),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: l10n.commonPhone)),
            const SizedBox(height: 12),
            TextField(controller: personController, decoration: const InputDecoration(labelText: 'Contact person')),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.commonAddress)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            if (nameController.text.trim().isEmpty) return;
            await ref.read(suppliersRepositoryProvider).createSupplier(
                  storeId: session.store!.id,
                  name: nameController.text.trim(),
                  contactPhone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  contactPerson: personController.text.trim().isEmpty ? null : personController.text.trim(),
                  address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                );
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
}
