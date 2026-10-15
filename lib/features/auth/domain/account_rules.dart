import '../../../core/constants/roles.dart';
import 'auth_models.dart';

/// Why an account change is refused. The same rules run on the server
/// (deactivate_employee / change_employee_role and the trigger on `users`);
/// this copy drives the local build and what the app offers.
enum AccountChangeRefusal { ownerProtected, onlyOwnerForManager, notYourself, notAllowed }

/// May [actor] deactivate [target]? Null when allowed.
///  * the owner's account: never (ownership moves by a separate process);
///  * a manager: only the owner, and nobody deactivates themselves;
///  * anyone else: the owner or a manager.
AccountChangeRefusal? canDeactivate(EmployeeRecord actor, EmployeeRecord target) {
  if (target.role == StoreRole.owner) return AccountChangeRefusal.ownerProtected;
  if (target.id == actor.id) return AccountChangeRefusal.notYourself;
  if (target.role == StoreRole.manager && actor.role != StoreRole.owner) {
    return AccountChangeRefusal.onlyOwnerForManager;
  }
  if (actor.role != StoreRole.owner && actor.role != StoreRole.manager) return AccountChangeRefusal.notAllowed;
  return null;
}

/// May [actor] give [target] the role [newRole]? Null when allowed. Nobody
/// becomes owner this way; making or unmaking a manager needs the owner.
AccountChangeRefusal? canChangeRole(EmployeeRecord actor, EmployeeRecord target, StoreRole newRole) {
  if (target.role == StoreRole.owner || newRole == StoreRole.owner) return AccountChangeRefusal.ownerProtected;
  if ((target.role == StoreRole.manager || newRole == StoreRole.manager) && actor.role != StoreRole.owner) {
    return AccountChangeRefusal.onlyOwnerForManager;
  }
  if (actor.role != StoreRole.owner && actor.role != StoreRole.manager) return AccountChangeRefusal.notAllowed;
  return null;
}

/// Whether [actor] may change [target]'s PIN: anyone their own; the owner
/// anyone's; a manager anyone's but the owner's or another manager's.
AccountChangeRefusal? canChangePin(EmployeeRecord actor, EmployeeRecord target) {
  if (actor.id == target.id || actor.role == StoreRole.owner) return null;
  if (actor.role != StoreRole.manager) return AccountChangeRefusal.notAllowed;
  if (target.role == StoreRole.owner || target.role == StoreRole.manager) {
    return AccountChangeRefusal.onlyOwnerForManager;
  }
  return null;
}

/// A refused account change, from the server or the local rules.
class AccountChangeException implements Exception {
  const AccountChangeException(this.refusal, {this.wrongPin = false});
  final AccountChangeRefusal? refusal;
  final bool wrongPin;
}

/// Too many wrong PINs in a row: sign-in waits [seconds] before trying again.
class PinLockedException implements Exception {
  const PinLockedException(this.seconds);
  final int seconds;
}

/// A PIN is four digits (what the sign-in pad takes).
bool isValidPin(String pin) => RegExp(r'^[0-9]{4}$').hasMatch(pin);
