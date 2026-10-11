import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/product_import.dart';
import '../domain/product_importer.dart';

/// Import products from an Excel or CSV file: pick the file, review what
/// was read (and which rows have problems), then import.
Future<void> showProductImportDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(context: context, builder: (_) => const _ProductImportDialog());
}

class _ProductImportDialog extends ConsumerStatefulWidget {
  const _ProductImportDialog();

  @override
  ConsumerState<_ProductImportDialog> createState() => _ProductImportDialogState();
}

class _ProductImportDialogState extends ConsumerState<_ProductImportDialog> {
  String? _fileName;
  ProductImportParseResult? _parsed;
  bool _readFailed = false;
  (int, int)? _progress;
  ProductImportSummary? _summary;

  Future<void> _saveTemplate() async {
    final l10n = AppLocalizations.of(context);
    final bytes = Uint8List.fromList(ProductImportParser.templateXlsx());
    const fileName = 'unopos_products.xlsx';
    final path = await FilePicker.platform.saveFile(fileName: fileName, bytes: bytes);
    // On desktop saveFile only returns the chosen path; write it ourselves.
    if (path != null && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await File(path).writeAsBytes(bytes);
    }
    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.importTemplateSaved)));
    }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return;
    final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) return;
    setState(() {
      _fileName = file.name;
      _summary = null;
      _readFailed = false;
      try {
        _parsed = file.name.toLowerCase().endsWith('.csv')
            ? ProductImportParser.parseCsv(utf8.decode(bytes, allowMalformed: true))
            : ProductImportParser.parseXlsx(bytes);
      } catch (_) {
        _parsed = null;
        _readFailed = true;
      }
    });
  }

  Future<void> _import() async {
    final parsed = _parsed;
    final session = ref.read(sessionControllerProvider);
    if (parsed == null || session.store == null) return;
    setState(() => _progress = (0, parsed.rows.length));
    final summary = await ProductImporter(ref.read(inventoryRepositoryProvider)).run(
      storeId: session.store!.id,
      rows: parsed.rows,
      branchId: session.currentBranchId,
      userId: session.employee?.id,
      onProgress: (done, total) {
        if (mounted) setState(() => _progress = (done, total));
      },
    );
    if (mounted) {
      setState(() {
        _progress = null;
        _summary = summary;
      });
    }
  }

  String _columnName(AppLocalizations l10n, ProductImportColumn c) => switch (c) {
        ProductImportColumn.name => l10n.commonName,
        ProductImportColumn.sellPrice => l10n.commonPrice,
        _ => c.name,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parsed = _parsed;
    final summary = _summary;
    final progress = _progress;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.importProductsTitle),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.importProductsHelp),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(l10n.importDownloadTemplate),
                    onPressed: progress == null ? _saveTemplate : null,
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.upload_file),
                    label: Text(l10n.importChooseFile),
                    onPressed: progress == null ? _pickFile : null,
                  ),
                ],
              ),
              if (_fileName != null) ...[
                const SizedBox(height: 16),
                Text(_fileName!, style: theme.textTheme.titleSmall),
              ],
              if (_readFailed) ...[
                const SizedBox(height: 8),
                Text(l10n.importReadFailed, style: TextStyle(color: theme.colorScheme.error)),
              ],
              if (parsed != null && summary == null) ...[
                const SizedBox(height: 8),
                Text(l10n.importRowsReady(parsed.rows.length)),
                for (final issue in parsed.issues.take(20))
                  Text(
                    issue.rowNumber == 0
                        ? l10n.importMissingColumn(_columnName(l10n, issue.field))
                        : l10n.importRowProblem(issue.rowNumber, _columnName(l10n, issue.field)),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                if (parsed.issues.length > 20) Text('… +${parsed.issues.length - 20}'),
              ],
              if (progress != null) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: progress.$2 == 0 ? null : progress.$1 / progress.$2),
                const SizedBox(height: 4),
                Text('${progress.$1} / ${progress.$2}'),
              ],
              if (summary != null) ...[
                const SizedBox(height: 16),
                Text(l10n.importDone(summary.created, summary.updated), style: theme.textTheme.titleSmall),
                if (summary.failedRows.isNotEmpty)
                  Text(
                    l10n.importFailedRows(summary.failedRows.join(', ')),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: progress == null ? () => Navigator.of(context).pop() : null,
          child: Text(l10n.actionClose),
        ),
        if (summary == null)
          FilledButton(
            onPressed: progress == null && (parsed?.rows.isNotEmpty ?? false) ? _import : null,
            child: Text(l10n.importProductsAction),
          ),
      ],
    );
  }
}
