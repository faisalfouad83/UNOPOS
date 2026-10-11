import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../debts/domain/debts_models.dart';

/// Pick the customer collecting loyalty points on this sale — search by
/// name or phone, or add a new one.
Future<CustomerRecord?> showLoyaltyCustomerPicker(BuildContext context, WidgetRef ref, String storeId) {
  return showDialog<CustomerRecord>(context: context, builder: (_) => _LoyaltyCustomerPicker(storeId: storeId));
}

class _LoyaltyCustomerPicker extends ConsumerStatefulWidget {
  const _LoyaltyCustomerPicker({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_LoyaltyCustomerPicker> createState() => _LoyaltyCustomerPickerState();
}

class _LoyaltyCustomerPickerState extends ConsumerState<_LoyaltyCustomerPicker> {
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _adding = false;
  bool _saving = false;

  @override
  void dispose() {
    _search.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final phone = _phone.text.trim();
    final customer = await ref
        .read(debtsRepositoryProvider)
        .createCustomer(widget.storeId, name, phone: phone.isEmpty ? null : phone);
    if (mounted) Navigator.of(context).pop(customer);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final customersStream = ref.watch(debtsRepositoryProvider).watchCustomers(widget.storeId);

    return AlertDialog(
      title: Text(l10n.loyaltyChooseCustomer),
      content: SizedBox(
        width: 420,
        height: 420,
        child: _adding
            ? Column(
                children: [
                  TextField(
                    controller: _name,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.commonName),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: l10n.posCustomerPhone, prefixIcon: const Icon(Icons.phone)),
                  ),
                ],
              )
            : Column(
                children: [
                  TextField(
                    controller: _search,
                    autofocus: true,
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<List<CustomerRecord>>(
                      stream: customersStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final q = _search.text.trim().toLowerCase();
                        final matches = snapshot.data!
                            .where((c) => q.isEmpty || c.name.toLowerCase().contains(q) || (c.phone ?? '').contains(q))
                            .toList()
                          ..sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
                        if (matches.isEmpty) return Center(child: Text(l10n.loyaltyNoMatches));
                        return ListView.builder(
                          itemCount: matches.length,
                          itemBuilder: (context, i) {
                            final c = matches[i];
                            return ListTile(
                              leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
                              title: Text(c.name),
                              subtitle: c.phone == null ? null : Text(c.phone!),
                              trailing: Text(l10n.loyaltyPointsBalance(c.loyaltyPoints)),
                              onTap: () => Navigator.of(context).pop(c),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        if (_adding)
          FilledButton(onPressed: _saving ? null : _create, child: Text(l10n.actionSave))
        else
          FilledButton.tonalIcon(
            icon: const Icon(Icons.person_add_alt),
            label: Text(l10n.loyaltyNewCustomer),
            onPressed: () => setState(() {
              _adding = true;
              _name.text = _search.text.trim();
            }),
          ),
      ],
    );
  }
}
