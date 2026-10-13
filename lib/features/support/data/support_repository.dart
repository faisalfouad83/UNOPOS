import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/support_models.dart';

/// Support chat and support-staff administration — shared backend only.
/// Every rule (who sees which conversation, who may send what, developer-
/// only administration) is enforced by the server.
class SupportRepository {
  SupportRepository(this._client);

  final SupabaseClient _client;

  // --- Store side --------------------------------------------------------

  /// The store's one conversation (created the first time).
  Future<String> myConversationId() async {
    final row = await _client.rpc('store_support_conversation') as Map<String, dynamic>;
    return row['id'] as String;
  }

  Future<void> storeSend(String body, String clientMessageId) async {
    await _client.rpc('store_send_support_message', params: {'p_body': body, 'p_client_message_id': clientMessageId});
  }

  Future<void> storeMarkRead() => _client.rpc('store_mark_support_read');

  /// Unread replies for the signed-in store (0 when it has no conversation).
  Stream<int> watchStoreUnread(String storeId) => _client
      .from('support_conversations')
      .stream(primaryKey: ['id'])
      .eq('store_id', storeId)
      .map((rows) => rows.isEmpty ? 0 : (rows.first['unread_for_store'] as num?)?.toInt() ?? 0);

  // --- Both sides --------------------------------------------------------

  /// The full history, live (RLS hides internal notes from the store).
  Stream<List<SupportMessageRecord>> watchMessages(String conversationId) => _client
      .from('support_messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', conversationId)
      .order('created_at')
      .map((rows) => rows.map(SupportMessageRecord.fromRow).toList());

  // --- Support team ------------------------------------------------------

  Future<bool> isSupportAgent() async => await _client.rpc('is_support_agent') as bool? ?? false;

  Future<SupportAgentRecord?> myAgentRecord() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client.from('support_agents').select().eq('auth_user_id', uid).maybeSingle();
    return row == null ? null : SupportAgentRecord.fromRow(row);
  }

  Future<List<SupportInboxEntry>> inbox({String? search, ConversationStatus? status}) async {
    final rows = await _client.rpc('support_inbox', params: {'p_search': search, 'p_status': status?.name}) as List;
    return rows.cast<Map<String, dynamic>>().map(SupportInboxEntry.fromRow).toList();
  }

  /// Fires whenever any conversation changes, to refresh the inbox.
  Stream<void> watchConversationChanges() =>
      _client.from('support_conversations').stream(primaryKey: ['id']).map((_) {});

  Future<void> agentSend(String conversationId, String body, String clientMessageId, {bool internal = false}) async {
    await _client.rpc('agent_send_support_message', params: {
      'p_conversation_id': conversationId,
      'p_body': body,
      'p_client_message_id': clientMessageId,
      'p_internal': internal,
    });
  }

  Future<void> updateConversation(String conversationId, {bool takeOver = false, ConversationStatus? status}) async {
    await _client.rpc('agent_update_conversation', params: {
      'p_conversation_id': conversationId,
      'p_take_over': takeOver,
      'p_status': status?.name,
    });
  }

  Future<void> heartbeat(String presence) => _client.rpc('support_heartbeat', params: {'p_presence': presence});

  // --- Developer: support staff administration ---------------------------

  Stream<List<SupportAgentRecord>> watchAgents() => _client
      .from('support_agents')
      .stream(primaryKey: ['id'])
      .order('full_name')
      .map((rows) => rows.map(SupportAgentRecord.fromRow).toList());

  Future<List<SupportAgentRecord>> listAgents() async {
    final rows = await _client.from('support_agents').select().order('full_name');
    return (rows as List).cast<Map<String, dynamic>>().map(SupportAgentRecord.fromRow).toList();
  }

  Future<Map<String, dynamic>> _admin(Map<String, dynamic> body) async {
    final res = await _client.functions.invoke('support-admin', body: body);
    final data = res.data;
    if (res.status != 200) {
      throw Exception(data is Map && data['error'] != null ? data['error'] : 'support-admin ${res.status}');
    }
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> createAgent({
    required String fullName,
    required String email,
    required String password,
    String phone = '',
    String address = '',
    String jobTitle = '',
    int salaryMinorUnits = 0,
    String notes = '',
  }) =>
      _admin({
        'action': 'create',
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
        'job_title': jobTitle,
        'salary_minor_units': salaryMinorUnits,
        'notes': notes,
      });

  Future<void> resetAgentPassword(String agentId, String password) =>
      _admin({'action': 'reset_password', 'agent_id': agentId, 'password': password});

  Future<void> setAgentEmployment(String agentId, SupportEmployment status) =>
      _admin({'action': 'set_status', 'agent_id': agentId, 'status': status.name});

  Future<void> updateAgent(SupportAgentRecord a) async {
    await _client.from('support_agents').update({
      'full_name': a.fullName,
      'phone': a.phone,
      'address': a.address,
      'job_title': a.jobTitle,
      'salary_minor_units': a.salaryMinorUnits,
      'notes': a.notes,
    }).eq('id', a.id);
  }

  Future<List<SalaryAdjustmentRecord>> salaryAdjustments(String agentId) async {
    final rows = await _client
        .from('support_salary_adjustments')
        .select()
        .eq('agent_id', agentId)
        .order('effective_date', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>().map(SalaryAdjustmentRecord.fromRow).toList();
  }

  Future<void> addSalaryAdjustment({
    required String agentId,
    required bool deduction,
    required int amountMinorUnits,
    required String reason,
    required DateTime effectiveDate,
  }) async {
    await _client.from('support_salary_adjustments').insert({
      'agent_id': agentId,
      'kind': deduction ? 'deduction' : 'bonus',
      'amount_minor_units': amountMinorUnits,
      'reason': reason,
      'effective_date':
          '${effectiveDate.year.toString().padLeft(4, '0')}-${effectiveDate.month.toString().padLeft(2, '0')}-${effectiveDate.day.toString().padLeft(2, '0')}',
    });
  }
}
