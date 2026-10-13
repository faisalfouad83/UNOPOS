import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/break_models.dart';

/// The break the signed-in employee is on. While set, the app shows only
/// the break screen (see RouteGuard) — their shift, cart and session stay
/// exactly as they were.
final activeBreakProvider = StateProvider<EmployeeBreakRecord?>((ref) => null);
