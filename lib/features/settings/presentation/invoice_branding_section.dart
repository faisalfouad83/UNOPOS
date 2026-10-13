import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../../printing/domain/receipt_models.dart';
import '../../printing/presentation/receipt_preview_dialog.dart';
import '../domain/settings_models.dart';

/// Image types a logo / product photo may be, and the largest file taken.
const allowedImageExtensions = ['png', 'jpg', 'jpeg', 'webp'];
const maxImageFileBytes = 5 * 1024 * 1024;

/// Decodes [bytes] (PNG/JPEG/WebP) and re-encodes it as a PNG no wider or
/// taller than [maxSide] pixels. Throws [FormatException] if it isn't an
/// image.
Future<Uint8List> resizeImageToPng(Uint8List bytes, {int maxSide = 384}) async {
  final ui.Codec codec;
  try {
    final probe = await ui.instantiateImageCodec(bytes);
    final frame = await probe.getNextFrame();
    final w = frame.image.width, h = frame.image.height;
    frame.image.dispose();
    final scale = (w > h ? w : h) > maxSide ? maxSide / (w > h ? w : h) : 1.0;
    codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: (w * scale).round().clamp(1, maxSide),
      targetHeight: (h * scale).round().clamp(1, maxSide),
    );
  } catch (_) {
    throw const FormatException('not an image');
  }
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  frame.image.dispose();
  if (data == null) throw const FormatException('not an image');
  return data.buffer.asUint8List();
}

/// Lets the user pick an image file and checks its type and size. Returns
/// null if cancelled; throws [FormatException] with a reason otherwise.
Future<Uint8List?> pickImageFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: allowedImageExtensions,
    withData: true,
  );
  final file = result?.files.singleOrNull;
  if (file == null) return null;
  final ext = (file.extension ?? '').toLowerCase();
  if (!allowedImageExtensions.contains(ext)) throw const FormatException('type');
  if (file.size > maxImageFileBytes) throw const FormatException('size');
  final bytes = file.bytes ?? (file.path == null ? null : await File(file.path!).readAsBytes());
  if (bytes == null) throw const FormatException('type');
  return bytes;
}

/// Settings › Invoice: the receipt template (paper + style) and the
/// store's branding printed on it, with a live preview.
class InvoiceBrandingSection extends ConsumerStatefulWidget {
  const InvoiceBrandingSection({super.key, required this.settings});
  final AppSettingsRecord settings;

  @override
  ConsumerState<InvoiceBrandingSection> createState() => _InvoiceBrandingSectionState();
}

class _InvoiceBrandingSectionState extends ConsumerState<InvoiceBrandingSection> {
  late final _name = TextEditingController(text: widget.settings.printerConfig.brandName);
  late final _phone = TextEditingController(text: widget.settings.printerConfig.brandPhone);
  late final _address = TextEditingController(text: widget.settings.printerConfig.brandAddress);
  late final _footer = TextEditingController(text: widget.settings.printerConfig.brandFooter);
  bool _saving = false;

  PrinterConfig get _config => widget.settings.printerConfig;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _footer.dispose();
    super.dispose();
  }

  Future<void> _save(PrinterConfig config) async {
    await ref.read(settingsRepositoryProvider).updateSettings(widget.settings.copyWith(printerConfig: config));
  }

  Future<void> _saveTexts() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await _save(
        _config.copyWith(
          brandName: _name.text.trim(),
          brandPhone: _phone.text.trim(),
          brandAddress: _address.text.trim(),
          brandFooter: _footer.text.trim(),
        ),
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickLogo() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await pickImageFile();
      if (bytes == null) return;
      final png = await resizeImageToPng(bytes);
      await _save(_config.copyWith(logoBase64: base64Encode(png), showLogo: true));
    } on FormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message == 'size' ? l10n.imageTooLarge : l10n.imageWrongType)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = _config;
    final logo = config.logoBase64 == null ? null : base64Decode(config.logoBase64!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.invoiceTemplateTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(l10n.invoicePaper, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ReceiptPaper>(
              segments: [
                ButtonSegment(
                    value: ReceiptPaper.thermal,
                    icon: const Icon(Icons.receipt),
                    label: Text(l10n.invoicePaperThermal)),
                const ButtonSegment(value: ReceiptPaper.a5, icon: Icon(Icons.description_outlined), label: Text('A5')),
                const ButtonSegment(value: ReceiptPaper.a4, icon: Icon(Icons.article_outlined), label: Text('A4')),
              ],
              selected: {config.paper},
              onSelectionChanged: (s) => _save(config.copyWith(paper: s.first)),
            ),
            const SizedBox(height: 12),
            Text(l10n.invoiceStyle, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ReceiptStyle>(
              segments: [
                ButtonSegment(value: ReceiptStyle.classic, label: Text(l10n.invoiceStyleClassic)),
                ButtonSegment(value: ReceiptStyle.modern, label: Text(l10n.invoiceStyleModern)),
                ButtonSegment(value: ReceiptStyle.compact, label: Text(l10n.invoiceStyleCompact)),
              ],
              selected: {config.style},
              onSelectionChanged: (s) => _save(config.copyWith(style: s.first)),
            ),
            const Divider(height: 32),
            Text(l10n.invoiceBranding, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logo == null
                      ? Icon(Icons.image_outlined, color: theme.colorScheme.outline)
                      : Image.memory(logo, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.upload),
                        label: Text(logo == null ? l10n.invoiceLogoChoose : l10n.invoiceLogoChange),
                        onPressed: _pickLogo,
                      ),
                      if (logo != null)
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.actionRemove),
                          onPressed: () => _save(config.copyWith(clearLogo: true, showLogo: false)),
                        ),
                      if (logo != null)
                        FilterChip(
                          label: Text(l10n.invoiceLogoShow),
                          selected: config.showLogo,
                          onSelected: (v) => _save(config.copyWith(showLogo: v)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.invoiceBrandName, helperText: l10n.invoiceBrandDefaultHint),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.commonPhone, prefixIcon: const Icon(Icons.phone)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: l10n.commonAddress, prefixIcon: const Icon(Icons.place_outlined)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _footer,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.invoiceFooter, hintText: l10n.receiptThankYou),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.actionSave),
                  onPressed: _saving ? null : _saveTexts,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.preview_outlined),
                  label: Text(l10n.printPreview),
                  onPressed: () {
                    final storeName = ref.read(sessionControllerProvider).store?.displayName ?? '';
                    // Preview what is typed, even before saving.
                    final preview = widget.settings.copyWith(
                      printerConfig: config.copyWith(
                        brandName: _name.text.trim(),
                        brandPhone: _phone.text.trim(),
                        brandAddress: _address.text.trim(),
                        brandFooter: _footer.text.trim(),
                      ),
                    );
                    showReceiptPreview(context, sampleReceipt(preview, storeName: storeName, l10n: l10n), preview);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
