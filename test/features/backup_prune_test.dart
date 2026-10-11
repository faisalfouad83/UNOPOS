import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:unopos/features/backup/domain/backup_models.dart';
import 'package:unopos/features/backup/domain/backup_service.dart';

void main() {
  test('only the newest automatic backups are kept; manual ones are never touched', () async {
    final dir = await Directory.systemTemp.createTemp('unopos_backups');
    addTearDown(() => dir.delete(recursive: true));
    for (var day = 1; day <= 5; day++) {
      await File(p.join(dir.path, '${backupFilePrefix(BackupType.automatic)}2026100${day}_220000.json')).writeAsString('{}');
    }
    await File(p.join(dir.path, '${backupFilePrefix(BackupType.manual)}20250101_090000.json')).writeAsString('{}');
    await File(p.join(dir.path, 'notes.txt')).writeAsString('keep');

    await pruneAutomaticBackups(dir.path, keep: 2);

    final names = dir.listSync().map((e) => p.basename(e.path)).toList()..sort();
    expect(names, [
      'notes.txt',
      'unopos_backup_20250101_090000.json',
      'unopos_backup_auto_20261004_220000.json',
      'unopos_backup_auto_20261005_220000.json',
    ]);
  });
}
