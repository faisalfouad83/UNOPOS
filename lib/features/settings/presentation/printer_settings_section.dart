import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../domain/settings_models.dart';

class PrinterSettingsSection extends ConsumerStatefulWidget {
  const PrinterSettingsSection({super.key, required this.settings});
  final AppSettingsRecord settings;

  @override
  ConsumerState<PrinterSettingsSection> createState() => _PrinterSettingsSectionState();
}

class _PrinterSettingsSectionState extends ConsumerState<PrinterSettingsSection> {
  late final TextEditingController _addressController =
      TextEditingController(text: widget.settings.printerConfig.connectionAddress);
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
    final needsAddress = config.driverType == 'network' || config.driverType == 'usb' || config.driverType == 'bluetooth';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsPrinter, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: config.driverType,
              decoration: const InputDecoration(labelText: 'Printer type'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('None')),
                DropdownMenuItem(value: 'network', child: Text('Network / WiFi (ESC-POS)')),
                DropdownMenuItem(value: 'usb', child: Text('USB thermal')),
                DropdownMenuItem(value: 'bluetooth', child: Text('Bluetooth thermal')),
                DropdownMenuItem(value: 'windowsSystem', child: Text('Windows system printer')),
              ],
              onChanged: (value) => _save(config.copyWith(driverType: value)),
            ),
            if (needsAddress) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: config.driverType == 'network' ? 'IP address:port (e.g. 192.168.1.50:9100)' : 'Connection address',
                ),
                onSubmitted: (v) => _save(config.copyWith(connectionAddress: v)),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: config.paperWidthMm,
              decoration: const InputDecoration(labelText: 'Paper width'),
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
                    setState(() => _testResult = ok ? 'OK' : 'Failed');
                  },
                  child: const Text('Test connection'),
                ),
                if (_testResult != null) ...[
                  const SizedBox(width: 12),
                  Text(_testResult!, style: TextStyle(color: _testResult == 'OK' ? Colors.green : Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
