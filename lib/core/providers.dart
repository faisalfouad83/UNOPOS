import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'supabase/supabase_client_provider.dart';
import 'supabase/supabase_config.dart';
import '../features/auth/data/auth_repository_drift.dart';
import '../features/auth/data/auth_repository_supabase.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/licensing/data/licensing_repository_drift.dart';
import '../features/licensing/data/licensing_repository_supabase.dart';
import '../features/licensing/domain/licensing_repository.dart';
import '../features/licensing/domain/license_gate_service.dart';
import '../features/accounting/data/accounting_repository_drift.dart';
import '../features/accounting/data/accounting_repository_supabase.dart';
import '../features/accounting/domain/accounting_repository.dart';
import '../features/accounting/domain/accounting_posting_service.dart';
import '../features/inventory/data/inventory_repository_drift.dart';
import '../features/inventory/data/inventory_repository_supabase.dart';
import '../features/inventory/domain/inventory_repository.dart';
import '../features/pos/data/pos_repository_drift.dart';
import '../features/pos/data/pos_repository_supabase.dart';
import '../features/pos/domain/pos_repository.dart';
import '../features/debts/data/debts_repository_drift.dart';
import '../features/debts/data/debts_repository_supabase.dart';
import '../features/debts/domain/debts_repository.dart';
import '../features/suppliers/data/suppliers_repository_drift.dart';
import '../features/suppliers/data/suppliers_repository_supabase.dart';
import '../features/suppliers/domain/suppliers_repository.dart';
import '../features/shifts/data/shifts_repository_drift.dart';
import '../features/shifts/data/shifts_repository_supabase.dart';
import '../features/shifts/domain/shifts_repository.dart';
import '../features/settings/data/settings_repository_drift.dart';
import '../features/settings/data/settings_repository_supabase.dart';
import '../features/settings/domain/settings_repository.dart';
import '../features/backup/data/backup_repository_drift.dart';
import '../features/backup/domain/backup_repository.dart';
import '../features/pos/domain/complete_sale_use_case.dart';
import '../features/pos/domain/process_sale_return_use_case.dart';
import '../features/printing/domain/printer_factory.dart';
import '../features/printing/domain/printer_service.dart';
import '../features/audit/data/audit_repository_drift.dart';
import '../features/audit/data/audit_repository_supabase.dart';
import '../features/audit/domain/audit_repository.dart';
import '../features/backup/domain/backup_service.dart';
import '../features/backup/domain/backup_service_supabase.dart';
import '../features/developer/data/developer_repository_supabase.dart';
import '../features/developer/domain/developer_repository.dart';
import '../features/notifications/data/notifications_repository_supabase.dart';
import '../features/notifications/domain/notifications_repository.dart';

/// The single AppDatabase instance for the whole app lifetime. Kept alive
/// for the entire process — never disposed mid-session. Only ever touched
/// when running on the local Drift backend (kUseSupabaseBackend == false).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Every repository provider below follows the same shape: Supabase when
/// kUseSupabaseBackend is true (see lib/core/supabase/supabase_config.dart),
/// Drift otherwise — the default, unchanged local behavior. Phase H1 cut
/// over Auth+Licensing; Phase H2 cuts over the remaining 8. Interfaces never
/// change, so every use case/screen above this file works unmodified either
/// way.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
  }
  return DriftAuthRepository(ref.watch(databaseProvider));
});

final licensingRepositoryProvider = Provider<LicensingRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseLicensingRepository(ref.watch(supabaseClientProvider));
  }
  return DriftLicensingRepository(ref.watch(databaseProvider));
});

final licenseGateServiceProvider = Provider<LicenseGateService>((ref) {
  return LicenseGateService(ref.watch(licensingRepositoryProvider));
});

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseAccountingRepository(ref.watch(supabaseClientProvider));
  }
  return DriftAccountingRepository(ref.watch(databaseProvider));
});

final accountingPostingServiceProvider = Provider<AccountingPostingService>((ref) {
  return AccountingPostingService(ref.watch(accountingRepositoryProvider));
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseInventoryRepository(ref.watch(supabaseClientProvider));
  }
  return DriftInventoryRepository(ref.watch(databaseProvider));
});

final posRepositoryProvider = Provider<PosRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabasePosRepository(ref.watch(supabaseClientProvider));
  }
  return DriftPosRepository(ref.watch(databaseProvider));
});

final debtsRepositoryProvider = Provider<DebtsRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseDebtsRepository(ref.watch(supabaseClientProvider));
  }
  return DriftDebtsRepository(ref.watch(databaseProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseSuppliersRepository(ref.watch(supabaseClientProvider));
  }
  return DriftSuppliersRepository(ref.watch(databaseProvider));
});

final shiftsRepositoryProvider = Provider<ShiftsRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseShiftsRepository(ref.watch(supabaseClientProvider));
  }
  return DriftShiftsRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseSettingsRepository(ref.watch(supabaseClientProvider));
  }
  return DriftSettingsRepository(ref.watch(databaseProvider));
});

/// Local file backups are inherently a local-device concept — stays
/// Drift-backed in both modes (see the SaaS migration plan).
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return DriftBackupRepository(ref.watch(databaseProvider));
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseAuditRepository(ref.watch(supabaseClientProvider));
  }
  return DriftAuditRepository(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupExportService>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseBackupService(ref.watch(backupRepositoryProvider), ref.watch(supabaseClientProvider));
  }
  return BackupService(ref.watch(backupRepositoryProvider));
});

/// Null on the local Drift build — there's no concept of "other stores" to
/// manage from a single install, so the Developer Console only renders its
/// full form (see developer_home_screen.dart) when this is non-null.
final developerRepositoryProvider = Provider<DeveloperRepository?>((ref) {
  if (!kUseSupabaseBackend) return null;
  return SupabaseDeveloperRepository(ref.watch(supabaseClientProvider));
});

/// Null on the local Drift build — same reasoning as developerRepositoryProvider.
final notificationsRepositoryProvider = Provider<NotificationsRepository?>((ref) {
  if (!kUseSupabaseBackend) return null;
  return SupabaseNotificationsRepository(ref.watch(supabaseClientProvider));
});

/// On Supabase, checkout/return run as one Postgres transaction each (see
/// supabase/migrations/0003_checkout_rpcs.sql) instead of the Drift path's
/// multi-repository orchestration — see complete_sale_use_case.dart's class
/// doc for why that's a deliberate improvement, not just a port.
final completeSaleUseCaseProvider = Provider<CompleteSaleUseCase>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseAtomicCompleteSaleUseCase(
      client: ref.watch(supabaseClientProvider),
      posRepository: ref.watch(posRepositoryProvider),
    );
  }
  return OrchestratedCompleteSaleUseCase(
    posRepository: ref.watch(posRepositoryProvider),
    inventoryRepository: ref.watch(inventoryRepositoryProvider),
    accountingPostingService: ref.watch(accountingPostingServiceProvider),
    debtsRepository: ref.watch(debtsRepositoryProvider),
  );
});

final processSaleReturnUseCaseProvider = Provider<ProcessSaleReturnUseCase>((ref) {
  if (kUseSupabaseBackend) {
    return SupabaseAtomicProcessSaleReturnUseCase(client: ref.watch(supabaseClientProvider));
  }
  return OrchestratedProcessSaleReturnUseCase(
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
