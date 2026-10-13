import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../domain/settings_models.dart';

class PrinterSettingsSection extends ConsumerStatefulWidget {
  const PrinterSettingsSection({super.key, required this.storeId, required this.settings});
  final String storeId;
  final AppSettingsRecord settings;

  @override
  ConsumerState<PrinterSettingsSection> createState() => _PrinterSettingsSectionState();
}

class _PrinterSettingsSectionState extends ConsumerState<PrinterSettingsSection> {
  late final TextEditingController _addressController = TextEditingController(
    text: widget.settings.printerConfig.connectionAddress,
  );
  String? _testResult;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save(PrinterConfig config) async {
    await ref.read(settingsRepositoryProvider).updateSettings(widget.settings.copyWith(printerConfig: config));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = widget.settings.printerConfig;
    final needsAddress =
        config.driverType == 'network' || config.driverType == 'usb' || config.driverType == 'bluetooth';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsPrinter, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(l10n.printModeTitle, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ReceiptPrintMode>(
              segments: [
                ButtonSegment(
                  value: ReceiptPrintMode.auto,
                  icon: const Icon(Icons.print),
                  label: Text(l10n.printModeAuto),
                ),
                ButtonSegment(
                  value: ReceiptPrintMode.ask,
                  icon: const Icon(Icons.help_outline),
                  label: Text(l10n.printModeAsk),
                ),
                ButtonSegment(
                  value: ReceiptPrintMode.off,
                  icon: const Icon(Icons.print_disabled_outlined),
                  label: Text(l10n.printModeOff),
                ),
              ],
              selected: {config.printMode},
              onSelectionChanged: (s) => _save(config.copyWith(printMode: s.first)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: config.driverType,
              decoration: InputDecoration(labelText: context.l10n.printerType),
              items: [
                DropdownMenuItem(value: 'none', child: Text(context.l10n.commonNone)),
                DropdownMenuItem(value: 'network', child: Text(context.l10n.printerNetwork)),
                DropdownMenuItem(value: 'usb', child: Text(context.l10n.printerUsb)),
                DropdownMenuItem(value: 'bluetooth', child: Text(context.l10n.printerBluetooth)),
                DropdownMenuItem(value: 'windowsSystem', child: Text(context.l10n.printerSystem)),
              ],
              onChanged: (value) => _save(config.copyWith(driverType: value)),
            ),
            if (config.driverType == 'windowsSystem') ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.print_outlined),
                title: Text(
                  (config.connectionAddress?.isNotEmpty ?? false) ? config.connectionAddress! : l10n.printerAskEachTime,
                ),
                subtitle: Text(l10n.printerSystemHelp),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final printer = await Printing.pickPrinter(context: context);
                        if (printer != null) await _save(config.copyWith(connectionAddress: printer.url));
                      },
                      child: Text(l10n.printerChoose),
                    ),
                    if (config.connectionAddress?.isNotEmpty ?? false)
                      IconButton(
                        tooltip: l10n.printerAskEachTime,
                        icon: const Icon(Icons.clear),
                        onPressed: () => _save(
                          PrinterConfig.fromJson({...config.toJson(), 'connectionAddress': null}),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (needsAddress) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: config.driverType == 'network'
                      ? context.l10n.printerAddressNetwork
                      : context.l10n.printerAddressGeneric,
                ),
                onSubmitted: (v) => _save(config.copyWith(connectionAddress: v)),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: config.paperWidthMm,
              decoration: InputDecoration(labelText: context.l10n.printerPaperWidth),
              items: const [
                DropdownMenuItem(value: 58, child: Text('58mm')),
                DropdownMenuItem(value: 80, child: Text('80mm')),
              ],
              onChanged: (value) => _save(config.copyWith(paperWidthMm: value)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final printer = buildPrinterService(config.driverType, paperWidthMm: config.paperWidthMm);
                    final ok = await printer.testConnection(_addressController.text);
                    setState(() => _testResult = ok ? context.l10n.printerTestOk : context.l10n.printerTestFailed);
                  },
                  child: Text(context.l10n.printerTestConnection),
                ),
                if (_testResult != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    _testResult!,
                    style: TextStyle(color: _testResult == 'OK' ? Colors.green : Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
