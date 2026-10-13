import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/providers.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../support/domain/support_models.dart';
import 'auth_models.dart';

class SessionState {
  const SessionState({
    this.store,
    this.employee,
    this.developerMode = false,
    this.currentBranchId,
    this.supportAgent,
  });

  final StoreRecord? store;

  /// Signed in to the support portal as this support employee (their own
  /// account, not a store).
  final SupportAgentRecord? supportAgent;
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
    bool clearBranch = false,
    bool clearDeveloperMode = false,
  }) {
    return SessionState(
      store: store ?? this.store,
      employee: clearEmployee ? null : (employee ?? this.employee),
      developerMode: clearDeveloperMode ? false : (developerMode ?? this.developerMode),
      currentBranchId: clearBranch ? null : (currentBranchId ?? this.currentBranchId),
      supportAgent: supportAgent,
    );
  }
}

enum PinResult { success, incorrect, developerGate, developerGateNeedsAuth }

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Future<void> loadExistingStore() async {
    final store = await ref.read(authRepositoryProvider).getCurrentStore();
    if (store != null) {
      state = state.copyWith(store: store);
    }
  }

  /// Signs this device into [store]. Anything belonging to a different
  /// store (account, branch) is dropped first, then the branch last used on
  /// this device for this store is restored.
  void setStore(StoreRecord store) {
    if (state.store?.id != store.id) {
      state = SessionState(store: store);
      ref.read(selectedEmployeeForPinProvider.notifier).state = null;
    } else {
      state = state.copyWith(store: store);
    }
    _restoreBranch(store.id);
  }

  Future<void> _restoreBranch(String storeId) async {
    if (state.currentBranchId != null) return;
    final saved = await BranchPreference.load(storeId);
    // Only if nothing changed meanwhile (same store, no branch picked yet).
    if (saved != null && state.store?.id == storeId && state.currentBranchId == null) {
      state = state.copyWith(currentBranchId: saved);
    }
  }

  /// Called from the PIN pad. Checks the magic developer/reset sequences
  /// first (per spec: 1313 works regardless of which tile was tapped), then
  /// falls back to verifying the PIN against the selected employee.
  Future<PinResult> submitPin(String pin, {EmployeeRecord? selectedEmployee}) async {
    if (pin == MagicPasscodes.developerGate) {
      if (kUseSupabaseBackend) {
        // 1313 is still the universal shortcut, but on the shared backend it
        // must not grant developer access by itself — it only reveals the
        // real sign-in form. Actual authorization happens in
        // signInDeveloper() below, checked server-side by RLS against
        // developer_admins, never by the client trusting a passcode alone.
        return PinResult.developerGateNeedsAuth;
      }
      state = state.copyWith(developerMode: true);
      return PinResult.developerGate;
    }

    if (selectedEmployee != null) {
      final ok = await ref.read(authRepositoryProvider).findEmployeeByPin(selectedEmployee.storeId, pin);
      if (ok != null && ok.id == selectedEmployee.id) {
        state = state.copyWith(employee: ok, clearDeveloperMode: true);
        await _resolveCurrentBranch(ok);
        await _closeLeftoverBreak(ok, pin);
        return PinResult.success;
      }
    }
    return PinResult.incorrect;
  }

  /// Real sign-in for the Developer Console on the shared Supabase backend,
  /// reached via the 1313 shortcut. Signs in with Supabase Auth, then
  /// requires the resulting account to actually be listed in
  /// `developer_admins` (enforced server-side by RLS/`is_developer_admin()`,
  /// not just checked here) before granting [SessionState.developerMode].
  /// Returns false — and signs the (non-developer) account back out — on
  /// any failure, so a valid store password can never masquerade as one.
  Future<bool> signInDeveloper(String email, String password) async {
    final client = ref.read(supabaseClientProvider);
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      return false;
    }

    final isDeveloper = await client.rpc('is_developer_admin') as bool? ?? false;
    if (!isDeveloper) {
      await client.auth.signOut();
      return false;
    }

    state = state.copyWith(developerMode: true);
    return true;
  }

  /// A break still open from before (the app was closed while the employee
  /// was away) ends now that they're back with their own PIN — recorded as
  /// reconciled, with any time over the limit. Best effort: signing in must
  /// not fail because of it.
  Future<void> _closeLeftoverBreak(EmployeeRecord employee, String pin) async {
    try {
      final breaks = ref.read(breaksRepositoryProvider);
      final open = await breaks.openBreakFor(employee.storeId, employee.id);
      if (open != null) await breaks.endBreak(breakId: open.id, pin: pin, reconciled: true);
    } catch (_) {}
  }

  /// Used only right after onboarding creates the founding owner account, so
  /// they land straight on the home screen without re-entering their PIN.
  Future<void> signInEmployeeDirectly(EmployeeRecord employee) async {
    state = state.copyWith(employee: employee, clearDeveloperMode: true);
    await _resolveCurrentBranch(employee);
  }

  /// If the employee is tied to a specific branch, use that; otherwise
  /// (e.g. an owner overseeing several branches) default to the store's
  /// main branch. Employees/owners can switch branches later from the
  /// dashboard if the store has more than one.
  Future<void> _resolveCurrentBranch(EmployeeRecord employee) async {
    if (employee.branchId != null) {
      state = state.copyWith(currentBranchId: employee.branchId);
      return;
    }
    // A branch already picked on the account screen wins.
    if (state.currentBranchId != null) return;
    final branches = await ref.read(authRepositoryProvider).listBranches(employee.storeId);
    if (branches.isEmpty) return;
    final main = branches.where((b) => b.isMainBranch).toList();
    state = state.copyWith(currentBranchId: (main.isNotEmpty ? main.first : branches.first).id);
  }

  /// The support portal's sign-in: the support employee's own account
  /// (email + password), which the server must recognise as active support
  /// staff — the 1414 entry code only opens this form. Anything else is
  /// signed straight back out.
  Future<bool> signInSupport(String email, String password) async {
    final client = ref.read(supabaseClientProvider);
    final repo = ref.read(supportRepositoryProvider);
    if (repo == null) return false;
    try {
      await client.auth.signInWithPassword(email: email, password: password);
    } on AuthException {
      return false;
    }
    final agent = await repo.isSupportAgent() ? await repo.myAgentRecord() : null;
    if (agent == null) {
      await client.auth.signOut();
      return false;
    }
    ref.read(selectedEmployeeForPinProvider.notifier).state = null;
    state = SessionState(supportAgent: agent);
    return true;
  }

  Future<void> signOutSupport() async {
    try {
      await ref.read(supportRepositoryProvider)?.heartbeat('signed_out');
    } catch (_) {}
    state = const SessionState();
    if (kUseSupabaseBackend) await ref.read(supabaseClientProvider).auth.signOut();
  }

  /// Sign out returns to the employee tile picker — the store-level session
  /// persists until the whole app process restarts.
  void signOutToTilePicker() {
    state = state.copyWith(clearEmployee: true, clearDeveloperMode: true);
  }

  /// Exiting the Developer Console on the shared Supabase backend: signing
  /// in as a developer replaced the single Supabase Auth session that had
  /// been authenticated as the store (one client, one session), so there is
  /// no store session left to "return to" — clearing local state and
  /// routing back to the tile picker would leave the client authenticated
  /// as the developer while the UI pretends to be the store, breaking any
  /// server-side call that resolves the store from auth.uid() (e.g.
  /// verify_employee_pin). Sign out for real and require a fresh store
  /// login instead.
  Future<void> signOutDeveloper() async {
    if (kUseSupabaseBackend) {
      await ref.read(supabaseClientProvider).auth.signOut();
    }
    state = const SessionState();
  }

  /// Leaving a store entirely (not just its employee/PIN session) — used by
  /// the tile picker's back button. Must actually sign out of Supabase, not
  /// just clear local state, or a persisted session would silently log the
  /// same store back in on the next app launch despite the user having
  /// "left" it (the same class of bug fixed for signOutDeveloper above).
  Future<void> signOutStore() async {
    // Clear first so nothing on screen keeps using the old store while the
    // sign-out request is in flight.
    state = const SessionState();
    ref.read(selectedEmployeeForPinProvider.notifier).state = null;
    if (kUseSupabaseBackend) {
      await ref.read(supabaseClientProvider).auth.signOut();
    }
  }

  /// Works in [branchId] from now on, and remembers it on this device for
  /// the next start. An account tied to one branch can't switch away from it.
  void setCurrentBranch(String branchId) {
    final assigned = state.employee?.branchId;
    if (assigned != null && assigned != branchId) return;
    state = state.copyWith(currentBranchId: branchId);
    final storeId = state.store?.id;
    if (storeId != null) BranchPreference.save(storeId, branchId);
  }

  /// Back to the branch list on the account screen.
  void clearCurrentBranch() {
    state = state.copyWith(clearBranch: true);
  }
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// The branch last worked in on this device, per store, so restarting the
/// app doesn't reset it.
class BranchPreference {
  const BranchPreference._();

  static String _key(String storeId) => 'session.branch.$storeId';

  static Future<String?> load(String storeId) async {
    try {
      return (await SharedPreferences.getInstance()).getString(_key(storeId));
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String storeId, String branchId) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_key(storeId), branchId);
    } catch (_) {}
  }
}

/// The store's branches (active and inactive), for showing and picking the
/// branch being worked in.
final storeBranchesProvider = FutureProvider.autoDispose.family<List<BranchRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).listBranches(storeId);
});

/// The employee tile tapped on the picker, carried over to the PIN pad
/// screen. Cleared once the PIN attempt resolves.
final selectedEmployeeForPinProvider = StateProvider<EmployeeRecord?>((ref) => null);
