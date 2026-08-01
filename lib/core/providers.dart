import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import '../features/auth/data/auth_repository_drift.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/licensing/data/licensing_repository_drift.dart';
import '../features/licensing/domain/licensing_repository.dart';
import '../features/licensing/domain/license_gate_service.dart';
import '../features/accounting/data/accounting_repository_drift.dart';
import '../features/accounting/domain/accounting_repository.dart';
import '../features/accounting/domain/accounting_posting_service.dart';
import '../features/inventory/data/inventory_repository_drift.dart';
import '../features/inventory/domain/inventory_repository.dart';
import '../features/pos/data/pos_repository_drift.dart';
import '../features/pos/domain/pos_repository.dart';
import '../features/debts/data/debts_repository_drift.dart';
import '../features/debts/domain/debts_repository.dart';
import '../features/suppliers/data/suppliers_repository_drift.dart';
import '../features/suppliers/domain/suppliers_repository.dart';
import '../features/shifts/data/shifts_repository_drift.dart';
import '../features/shifts/domain/shifts_repository.dart';
import '../features/settings/data/settings_repository_drift.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/backup/data/backup_repository_drift.dart';
import '../features/backup/domain/backup_repository.dart';
import '../features/pos/domain/complete_sale_use_case.dart';
import '../features/printing/domain/printer_factory.dart';
import '../features/printing/domain/printer_service.dart';
import '../features/audit/data/audit_repository_drift.dart';
import '../features/audit/domain/audit_repository.dart';
import '../features/backup/domain/backup_service.dart';

/// The single AppDatabase instance for the whole app lifetime. Kept alive
/// for the entire process — never disposed mid-session.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DriftAuthRepository(ref.watch(databaseProvider));
});

final licensingRepositoryProvider = Provider<LicensingRepository>((ref) {
  return DriftLicensingRepository(ref.watch(databaseProvider));
});

final licenseGateServiceProvider = Provider<LicenseGateService>((ref) {
  return LicenseGateService(ref.watch(licensingRepositoryProvider));
});

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  return DriftAccountingRepository(ref.watch(databaseProvider));
});

final accountingPostingServiceProvider = Provider<AccountingPostingService>((ref) {
  return AccountingPostingService(ref.watch(accountingRepositoryProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return DriftInventoryRepository(ref.watch(databaseProvider));
});

final posRepositoryProvider = Provider<PosRepository>((ref) {
  return DriftPosRepository(ref.watch(databaseProvider));
});

final debtsRepositoryProvider = Provider<DebtsRepository>((ref) {
  return DriftDebtsRepository(ref.watch(databaseProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return DriftSuppliersRepository(ref.watch(databaseProvider));
});

final shiftsRepositoryProvider = Provider<ShiftsRepository>((ref) {
  return DriftShiftsRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return DriftSettingsRepository(ref.watch(databaseProvider));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return DriftBackupRepository(ref.watch(databaseProvider));
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return DriftAuditRepository(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(backupRepositoryProvider));
});

final completeSaleUseCaseProvider = Provider<CompleteSaleUseCase>((ref) {
  return CompleteSaleUseCase(
    posRepository: ref.watch(posRepositoryProvider),
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    accountingPostingService: ref.watch(accountingPostingServiceProvider),
    debtsRepository: ref.watch(debtsRepositoryProvider),
  );
});

/// Builds a fresh driver instance per print job from the store's current
/// PrinterConfig — thermal/print connections are cheap to open and close
/// per receipt rather than held open for the app's whole lifetime.
PrinterService buildPrinterService(String driverType, {int paperWidthMm = 58}) {
  return PrinterFactory.create(driverType, paperWidthMm: paperWidthMm);
}
