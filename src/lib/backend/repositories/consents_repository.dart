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
}
