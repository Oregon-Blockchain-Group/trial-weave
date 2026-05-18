import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/consent.dart';

class ConsentsRepository {
  ConsentsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'consents';

  /// Records a fresh consent decision. Each call creates a new row — older
  /// consents stay in the table for audit/regulatory reasons.
  Future<Consent> insert({
    required String version,
    required Map<String, dynamic> grants,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final row = await _client
        .from(_table)
        .insert({'user_id': userId, 'version': version, 'grants': grants})
        .select()
        .single();
    return Consent.fromJson(row);
  }

  /// Returns the caller's most recent consent row, or null if none exists.
  Future<Consent?> latest() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('granted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return Consent.fromJson(row);
  }
}
