import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backup_models.dart';
import 'backup_repository.dart';
import 'backup_service.dart';

/// Tenant tables included in a Supabase backup, in an order that respects
/// foreign keys on restore (a table only appears after every table it
/// references). `employee_credentials` is deliberately excluded — RLS grants
/// it zero SELECT policies for the `authenticated` role by design (see
/// migration 0001), so a client can never read PIN hashes even to back them
/// up; restoring a store re-creates employees but not their PINs, which
/// each employee simply resets afterward.
const _backupTables = [
  'branches',
  'categories',
  'tax_rates',
  'products',
  'users',
  'stock_items',
  'stock_movements',
  'suppliers',
  'supplier_transactions',
  'customers',
  'discounts',
  'chart_of_accounts',
  'journal_entries',
  'journal_lines',
  'sales',
  'sale_lines',
  'sale_returns',
  'sale_return_lines',
  'debt_ledger_entries',
  'debt_payments',
  'purchase_orders',
  'purchase_order_lines',
  'stock_transfers',
  'stock_transfer_lines',
  'shifts',
  'app_settings',
  'audit_logs',
];

/// Same public shape as [BackupService] (the local Drift build's backup
/// service) so `backup_settings_section.dart` needs no changes when this is
/// swapped in for the Supabase build — only the storage format differs: a
/// JSON file of the store's actual Supabase rows, not a zip of a local
/// sqlite file (which is empty/irrelevant once the app runs on Supabase).
/// Backup *history* still logs through the same Drift-backed
/// [BackupRepository] — that log is a local artifact of "when did this
/// machine last write a backup file", not tenant data, so there's nothing
/// wrong with it staying local regardless of backend.
class SupabaseBackupService implements BackupExportService {
  SupabaseBackupService(this._repository, this._client);

  final BackupRepository _repository;
  final SupabaseClient _client;

  String _timestampSuffix(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }

  @override
  Future<BackupLogRecord> performBackup({
    required String storeId,
    required String destinationFolderPath,
    required BackupType type,
  }) async {
    try {
      final tables = <String, List<Map<String, dynamic>>>{};
      for (final table in _backupTables) {
        final rows = await _client.from(table).select();
        tables[table] = List<Map<String, dynamic>>.from(rows as List);
      }

      final payload = {
        'format': 'unopos_supabase_backup_v1',
        'store_id': storeId,
        'exported_at': DateTime.now().toIso8601String(),
        'tables': tables,
      };

      final jsonPath = p.join(destinationFolderPath, 'unopos_backup_${_timestampSuffix(DateTime.now())}.json');
      final jsonFile = File(jsonPath);
      await jsonFile.writeAsString(jsonEncode(payload));

      final size = await jsonFile.length();
      return _repository.logBackup(
        storeId: storeId,
        filePath: jsonPath,
        sizeBytes: size,
        type: type,
        status: BackupStatus.success,
      );
    } catch (e) {
      return _repository.logBackup(
        storeId: storeId,
        filePath: destinationFolderPath,
        sizeBytes: 0,
        type: type,
        status: BackupStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Upserts every row back into its table, in the same dependency-safe
  /// order used for export. This restores/overwrites matching rows (by id)
  /// but does not delete rows created since the backup was taken — a full
  /// wipe-and-replace would risk destroying newer data on a partial failure
  /// partway through, which is worse than leaving a few extra rows behind.
  @override
  Future<void> restoreFromBackup(String backupJsonPath) async {
    final content = await File(backupJsonPath).readAsString();
    final payload = jsonDecode(content) as Map<String, dynamic>;
    final tables = payload['tables'] as Map<String, dynamic>;

    for (final table in _backupTables) {
      final rows = tables[table];
      if (rows == null) continue;
      final rowList = List<Map<String, dynamic>>.from(rows as List);
      if (rowList.isEmpty) continue;
      await _client.from(table).upsert(rowList);
    }
  }

  @override
  Future<bool> hasBackupToday(String storeId) async {
    final recent = await _repository.mostRecentSuccessfulBackup(storeId, onlyToday: true);
    return recent != null;
  }
}
