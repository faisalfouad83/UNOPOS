import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/store_reset/store_reset_service.dart';

/// Saves the pre-reset backup where the owner chooses: on Windows (and
/// other desktops) a "Save as" dialog, on Android the system's document
/// picker (which writes the file itself). A second copy always goes to the
/// app's own folder (`store_reset_backups`).
///
/// Reading back: the chosen file when it can be opened by path (desktop,
/// and Android when the picker gives a real path); otherwise the app's own
/// copy, which holds the very same bytes.
class FileBackupSink implements BackupSink {
  FileBackupSink({required this.dialogTitle});

  final String dialogTitle;

  static bool get _desktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  Future<SavedBackup?> save(String fileName, Uint8List bytes) async {
    final String? chosen;
    if (_desktop) {
      chosen = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: const ['json'],
        lockParentWindow: true,
      );
      if (chosen == null) return null;
      final file = File(chosen.toLowerCase().endsWith('.json') ? chosen : '$chosen.json');
      await file.writeAsBytes(bytes, flush: true);
      final copy = await _keepCopy(fileName, bytes);
      return SavedBackup(location: file.path, copyPath: copy);
    }
    chosen = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
    if (chosen == null) return null;
    final copy = await _keepCopy(fileName, bytes);
    return SavedBackup(location: chosen, copyPath: copy);
  }

  @override
  Future<Uint8List> readBack(SavedBackup saved) async {
    final chosen = File(saved.location);
    if (await chosen.exists()) return chosen.readAsBytes();
    final copy = saved.copyPath;
    if (copy != null) return File(copy).readAsBytes();
    throw FileSystemException('The saved backup cannot be read back', saved.location);
  }

  static Future<String?> _keepCopy(String fileName, Uint8List bytes) async {
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory(p.join(base.path, 'store_reset_backups'));
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
