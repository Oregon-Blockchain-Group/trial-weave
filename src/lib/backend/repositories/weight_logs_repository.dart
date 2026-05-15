import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/weight_log.dart';

class WeightLogsRepository {
  WeightLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'weight_logs';

  /// Inserts a new weight entry. Multiple entries on the same day are allowed;
  /// each save creates its own row keyed by the surrogate `id`.
  Future<void> insert({
    required DateTime loggedAt,
    required double weightLb,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from(_table).insert({
      'user_id': userId,
      'logged_at': loggedAt.toUtc().toIso8601String(),
      'weight_lb': weightLb,
    });
  }

  /// Most recent [limit] weight logs, newest first. Used by the home Weight
  /// tile.
  Future<List<WeightLog>> listRecent({int limit = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('logged_at', ascending: false)
        .limit(limit);
    return rows.map((r) => WeightLog.fromJson(r)).toList();
  }

  /// All weight logs since [since], oldest first. Used by the Progress
  /// screen's full chart so the line plots in chronological order.
  Future<List<WeightLog>> listSince(DateTime since) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .gte('logged_at', since.toUtc().toIso8601String())
        .order('logged_at', ascending: true);
    return rows.map((r) => WeightLog.fromJson(r)).toList();
  }
}
