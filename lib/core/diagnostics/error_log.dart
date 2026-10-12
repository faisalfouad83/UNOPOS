import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A small on-disk log of startup steps and uncaught errors, so a problem on
/// a shop's PC can be read back afterwards (the release app has no console).
/// Lives at `<app support dir>/logs/unopos.log`, e.g.
/// %APPDATA%\com.unopos\UNOPOS\logs\unopos.log on Windows.
class ErrorLog {
  ErrorLog._();

  static File? _file;

  static Future<void> init() async {
    try {
      final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'logs'));
      await dir.create(recursive: true);
      final file = File(p.join(dir.path, 'unopos.log'));
      // Keep it small: start over once it passes ~256 KB.
      if (await file.exists() && await file.length() > 256 * 1024) await file.writeAsString('');
      _file = file;
    } catch (_) {
      _file = null;
    }
  }

  static String? get path => _file?.path;

  static void write(String message, [StackTrace? stack]) {
    final file = _file;
    if (file == null) return;
    final buffer = StringBuffer('[${DateTime.now().toIso8601String()}] $message\n');
    if (stack != null) buffer.writeln(stack.toString().split('\n').take(25).join('\n'));
    try {
      file.writeAsStringSync(buffer.toString(), mode: FileMode.append, flush: true);
    } catch (_) {}
  }
}
