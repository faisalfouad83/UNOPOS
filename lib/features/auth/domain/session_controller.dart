import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/providers.dart';
import 'auth_models.dart';

class SessionState {
  const SessionState({
    this.store,
    this.employee,
    this.developerMode = false,
    this.currentBranchId,
  });

  final StoreRecord? store;
  final EmployeeRecord? employee;
  final bool developerMode;
  final String? currentBranchId;

  bool get hasStore => store != null;
  bool get isEmployeeSignedIn => employee != null;
  bool get isAuthenticated => developerMode || employee != null;

  SessionRole? get role {
    if (developerMode) return SessionRole.developer;
    if (employee == null) return null;
    return SessionRole.fromStoreRole(employee!.role);
  }

  SessionState copyWith({
    StoreRecord? store,
    EmployeeRecord? employee,
    bool? developerMode,
    String? currentBranchId,
    bool clearEmployee = false,
    bool clearDeveloperMode = false,
  }) {
    return SessionState(
      store: store ?? this.store,
      employee: clearEmployee ? null : (employee ?? this.employee),
      developerMode: clearDeveloperMode ? false : (developerMode ?? this.developerMode),
      currentBranchId: currentBranchId ?? this.currentBranchId,
    );
  }
}

enum PinResult { success, incorrect, developerGate }

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Future<void> loadExistingStore() async {
    final store = await ref.read(authRepositoryProvider).getCurrentStore();
    if (store != null) {
      state = state.copyWith(store: store);
    }
  }

  void setStore(StoreRecord store) {
    state = state.copyWith(store: store);
  }

  /// Called from the PIN pad. Checks the magic developer/reset sequences
  /// first (per spec: 1313 works regardless of which tile was tapped), then
  /// falls back to verifying the PIN against the selected employee.
  Future<PinResult> submitPin(String pin, {EmployeeRecord? selectedEmployee}) async {
    if (pin == MagicPasscodes.developerGate) {
      state = state.copyWith(developerMode: true);
      return PinResult.developerGate;
    }

    if (selectedEmployee != null) {
      final ok = await ref.read(authRepositoryProvider).findEmployeeByPin(selectedEmployee.storeId, pin);
      if (ok != null && ok.id == selectedEmployee.id) {
        state = state.copyWith(employee: ok, clearDeveloperMode: true);
        return PinResult.success;
      }
    }
    return PinResult.incorrect;
  }

  /// Used only right after onboarding creates the founding owner account, so
  /// they land straight on the home screen without re-entering their PIN.
  void signInEmployeeDirectly(EmployeeRecord employee) {
    state = state.copyWith(employee: employee, clearDeveloperMode: true);
  }

  /// Sign out returns to the employee tile picker — the store-level session
  /// persists until the whole app process restarts.
  void signOutToTilePicker() {
    state = state.copyWith(clearEmployee: true, clearDeveloperMode: true);
  }

  void signOutStore() {
    state = const SessionState();
  }

  void setCurrentBranch(String branchId) {
    state = state.copyWith(currentBranchId: branchId);
  }
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// The employee tile tapped on the picker, carried over to the PIN pad
/// screen. Cleared once the PIN attempt resolves.
final selectedEmployeeForPinProvider = StateProvider<EmployeeRecord?>((ref) => null);
