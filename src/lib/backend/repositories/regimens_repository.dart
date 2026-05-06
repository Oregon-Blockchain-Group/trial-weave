import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/regimen.dart';

class RegimensRepository {
  RegimensRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'regimens';

  /// Ends any active regimen for the caller, then creates a new active one
  /// in a single sequence. The schema's partial unique index
  /// `regimens_one_active_per_user` enforces at-most-one-active; this method
  /// honors that invariant by deactivating before insert.
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

    await _client
        .from(_table)
        .update({'is_active': false, 'ended_at': now.toIso8601String()})
        .eq('user_id', userId)
        .eq('is_active', true);

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

  /// Marks the active regimen inactive without starting a new one. Used by
  /// the Regimen screen's "Stop drug" action.
  Future<void> endActive() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final now = DateTime.now().toUtc();
    await _client
        .from(_table)
        .update({'is_active': false, 'ended_at': now.toIso8601String()})
        .eq('user_id', userId)
        .eq('is_active', true);
  }
}
