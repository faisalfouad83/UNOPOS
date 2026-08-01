import 'package:uuid/uuid.dart';

/// Every entity in UNOPOS is identified by a v4 UUID rather than an
/// autoincrement integer — this is what makes syncing local rows to a
/// future shared Supabase/Firebase backend possible without ID collisions.
class IdGenerator {
  const IdGenerator._();

  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
