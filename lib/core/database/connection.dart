import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens (or creates) the single local SQLite file UNOPOS stores everything
/// in, under the platform's application-support directory so it survives
/// app updates and isn't visible to other apps.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationSupportDirectory();
    final dbFile = File(p.join(dir.path, 'unopos.sqlite'));
    return NativeDatabase.createInBackground(
      dbFile,
      logStatements: false,
    );
  });
}

/// Path to the live database file — used by the backup feature to copy it.
Future<String> resolveDatabaseFilePath() async {
  final dir = await getApplicationSupportDirectory();
  return p.join(dir.path, 'unopos.sqlite');
}

/// In-memory database for unit tests — never touches disk.
QueryExecutor openTestConnection() {
  return NativeDatabase.memory();
}
