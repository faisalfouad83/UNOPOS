enum SupportEmployment {
  active,
  suspended,
  terminated;

  static SupportEmployment fromName(String? n) =>
      SupportEmployment.values.where((e) => e.name == n).firstOrNull ?? SupportEmployment.active;
}

/// What a support employee's status really is right now. The app reports
/// in every minute; a report older than [staleAfter] isn't trusted and
/// shows as disconnected (the app was closed or lost its connection).
enum SupportPresence { online, onBreak, signedOut, disconnected }

const staleAfter = Duration(minutes: 2);

class SupportAgentRecord {
  const SupportAgentRecord({
    required this.id,
    this.authUserId,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.address = '',
    this.jobTitle = '',
    this.salaryMinorUnits = 0,
    this.employment = SupportEmployment.active,
    this.reportedPresence = 'signed_out',
    this.lastSeenAt,
    required this.createdAt,
    this.notes = '',
  });

  final String id;
  final String? authUserId;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String jobTitle;
  final int salaryMinorUnits;
  final SupportEmployment employment;

  /// As last reported by the app: online / break / signed_out.
  final String reportedPresence;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final String notes;

  SupportPresence presence([DateTime? now]) {
    if (reportedPresence == 'signed_out' || employment != SupportEmployment.active) return SupportPresence.signedOut;
    final seen = lastSeenAt;
    if (seen == null || (now ?? DateTime.now()).difference(seen) > staleAfter) return SupportPresence.disconnected;
    return reportedPresence == 'break' ? SupportPresence.onBreak : SupportPresence.online;
  }

  factory SupportAgentRecord.fromRow(Map<String, dynamic> r) => SupportAgentRecord(
        id: r['id'] as String,
        authUserId: r['auth_user_id'] as String?,
        fullName: r['full_name'] as String,
        email: r['email'] as String,
        phone: (r['phone'] as String?) ?? '',
        address: (r['address'] as String?) ?? '',
        jobTitle: (r['job_title'] as String?) ?? '',
        salaryMinorUnits: (r['salary_minor_units'] as num?)?.toInt() ?? 0,
        employment: SupportEmployment.fromName(r['employment_status'] as String?),
        reportedPresence: (r['presence'] as String?) ?? 'signed_out',
        lastSeenAt: r['last_seen_at'] == null ? null : DateTime.parse(r['last_seen_at'] as String).toLocal(),
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        notes: (r['notes'] as String?) ?? '',
      );
}

class SalaryAdjustmentRecord {
  const SalaryAdjustmentRecord({
    required this.id,
    required this.agentId,
    required this.isDeduction,
    required this.amountMinorUnits,
    required this.reason,
    required this.effectiveDate,
    required this.createdAt,
  });

  final String id;
  final String agentId;
  final bool isDeduction;
  final int amountMinorUnits;
  final String reason;
  final DateTime effectiveDate;
  final DateTime createdAt;

  factory SalaryAdjustmentRecord.fromRow(Map<String, dynamic> r) => SalaryAdjustmentRecord(
        id: r['id'] as String,
        agentId: r['agent_id'] as String,
        isDeduction: r['kind'] == 'deduction',
        amountMinorUnits: (r['amount_minor_units'] as num).toInt(),
        reason: r['reason'] as String,
        effectiveDate: DateTime.parse(r['effective_date'] as String),
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );
}

enum ConversationStatus {
  open,
  pending,
  closed;

  static ConversationStatus fromName(String? n) =>
      ConversationStatus.values.where((s) => s.name == n).firstOrNull ?? ConversationStatus.open;
}

/// A store's conversation as the support inbox lists it, with the store's
/// details.
class SupportInboxEntry {
  const SupportInboxEntry({
    required this.conversationId,
    required this.storeId,
    required this.storeLoginId,
    required this.storeName,
    this.ownerName = '',
    this.phone = '',
    this.address = '',
    this.activationStatus = '',
    this.expiresAt,
    required this.status,
    this.assignedAgentId,
    this.assignedAgentName,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessagePreview = '',
    this.unread = 0,
  });

  final String conversationId;
  final String storeId;
  final String storeLoginId;
  final String storeName;
  final String ownerName;
  final String phone;
  final String address;
  final String activationStatus;
  final DateTime? expiresAt;
  final ConversationStatus status;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String lastMessagePreview;
  final int unread;

  factory SupportInboxEntry.fromRow(Map<String, dynamic> r) => SupportInboxEntry(
        conversationId: r['conversation_id'] as String,
        storeId: r['store_id'] as String,
        storeLoginId: (r['store_login_id'] as String?) ?? '',
        storeName: (r['store_name'] as String?) ?? '',
        ownerName: (r['owner_name'] as String?) ?? '',
        phone: (r['phone'] as String?) ?? '',
        address: (r['address'] as String?) ?? '',
        activationStatus: (r['activation_status'] as String?) ?? '',
        expiresAt: r['expires_at'] == null ? null : DateTime.parse(r['expires_at'] as String).toLocal(),
        status: ConversationStatus.fromName(r['status'] as String?),
        assignedAgentId: r['assigned_agent_id'] as String?,
        assignedAgentName: r['assigned_agent_name'] as String?,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
        lastMessageAt: DateTime.parse(r['last_message_at'] as String).toLocal(),
        lastMessagePreview: (r['last_message_preview'] as String?) ?? '',
        unread: (r['unread_for_support'] as num?)?.toInt() ?? 0,
      );
}

class SupportMessageRecord {
  const SupportMessageRecord({
    required this.id,
    required this.conversationId,
    required this.fromStore,
    this.senderAgentId,
    required this.senderName,
    required this.body,
    this.isInternalNote = false,
    required this.clientMessageId,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final bool fromStore;
  final String? senderAgentId;

  /// The sender's name as it was when they wrote it.
  final String senderName;
  final String body;
  final bool isInternalNote;
  final String clientMessageId;
  final DateTime createdAt;

  factory SupportMessageRecord.fromRow(Map<String, dynamic> r) => SupportMessageRecord(
        id: r['id'] as String,
        conversationId: r['conversation_id'] as String,
        fromStore: r['sender_type'] == 'store',
        senderAgentId: r['sender_agent_id'] as String?,
        senderName: (r['sender_name'] as String?) ?? '',
        body: r['body'] as String,
        isInternalNote: r['is_internal_note'] as bool? ?? false,
        clientMessageId: r['client_message_id'] as String,
        createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
      );
}

/// A message the user is sending: shown at once, marked failed if it
/// couldn't be sent (retry re-sends with the same id, so it never doubles).
class OutgoingMessage {
  const OutgoingMessage(
      {required this.clientMessageId, required this.body, this.failed = false, this.internal = false});
  final String clientMessageId;
  final String body;
  final bool failed;
  final bool internal;

  OutgoingMessage asFailed() =>
      OutgoingMessage(clientMessageId: clientMessageId, body: body, failed: true, internal: internal);
  OutgoingMessage asSending() => OutgoingMessage(clientMessageId: clientMessageId, body: body, internal: internal);
}

/// Messages to show: the server's (the record) plus the user's own that
/// haven't come back from the server yet, in time order, no duplicates.
List<Object> mergeMessages(List<SupportMessageRecord> server, List<OutgoingMessage> outgoing) {
  final sent = server.map((m) => m.clientMessageId).toSet();
  final sorted = [...server]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return [...sorted, ...outgoing.where((o) => !sent.contains(o.clientMessageId))];
}

/// The support team's phone number, shown on every support chat.
const supportPhoneNumber = '07739918389';
