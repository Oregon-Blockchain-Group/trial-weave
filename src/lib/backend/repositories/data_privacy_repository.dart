import 'package:supabase_flutter/supabase_flutter.dart';

/// Combines an export-all read with the delete_account RPC. RLS scopes
/// every read to the caller, so a user can only ever export their own data.
class DataPrivacyRepository {
  DataPrivacyRepository(this._client);
  final SupabaseClient _client;

  /// Bundles every row the caller owns across all 8 tables into a single
  /// JSON-shaped Map. The Edit Profile / Data Privacy screens render this
  /// with `JsonEncoder.withIndent`.
  Future<Map<String, dynamic>> exportAll() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('not authenticated');
    }

    Future<List<Map<String, dynamic>>> all(String table) async {
      final rows = await _client.from(table).select().eq('user_id', userId);
      return rows.cast<Map<String, dynamic>>();
    }

    return {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'user_id': userId,
      'profiles': await all('profiles'),
      'regimens': await all('regimens'),
      'dose_logs': await all('dose_logs'),
      'weight_logs': await all('weight_logs'),
      'side_effect_logs': await all('side_effect_logs'),
      'factor_logs': await all('factor_logs'),
      'cost_logs': await all('cost_logs'),
      'consents': await all('consents'),
    };
  }

  /// Calls the delete_account SECURITY DEFINER RPC defined in
  /// supabase/migrations/0001_init.sql. Cascading FKs remove all the
  /// caller's rows; the auth.users row is deleted too. Caller should
  /// sign out and route to /welcome after this resolves.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_account');
  }
}
