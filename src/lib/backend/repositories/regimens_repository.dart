import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/regimen.dart';

class RegimensRepository {
  RegimensRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'regimens';

  /// Creates a new active regimen. Caller must ensure no other regimen is
  /// active first (use [stopActive] with a reason); the schema's partial
  /// unique index `regimens_one_active_per_user` will reject an insert
  /// otherwise.
  Future<Regimen> startNew({
    required String brand,
    String? generic,
    String? dose,
    String? form,
    String? frequency,
    String? indication,
    String? priorGlp1,
    String? supply,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final now = DateTime.now().toUtc();

    final row = await _client
        .from(_table)
        .insert({
          'user_id': userId,
          'brand': brand,
          'generic': generic,
          'dose': dose,
          'form': form,
          'frequency': frequency,
          'indication': indication,
          'prior_glp1': priorGlp1,
          'supply': supply,
          'started_at': now.toIso8601String(),
          'is_active': true,
        })
        .select()
        .single();
    return Regimen.fromJson(row);
  }

  /// Returns the caller's active regimen, or null if they have none.
  Future<Regimen?> currentActive() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .maybeSingle();
    if (row == null) return null;
    return Regimen.fromJson(row);
  }

  /// All of the caller's regimens, newest first. Used by the Regimen
  /// screen's history list.
  Future<List<Regimen>> listAll() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false);
    return rows.map((r) => Regimen.fromJson(r)).toList();
  }

  /// Audited deactivation of the caller's active regimen. No-ops on the
  /// server if nothing is active. Routes through the `stop_regimen` RPC,
  /// which writes audit_log rows in the same transaction. Direct updates
  /// to `regimens` are blocked by RLS.
  Future<void> stopActive({required String reason}) async {
    await _client.rpc('stop_regimen', params: {'p_reason': reason});
  }
}
