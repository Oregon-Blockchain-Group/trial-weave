import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/weight_log.dart';

class WeightLogsRepository {
  WeightLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'weight_logs';

  /// Upserts on the (user_id, date) composite PK. Logging twice on the same
  /// day overwrites — by design.
  Future<void> upsertOnDate({
    required DateTime date,
    required double weightLb,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final dateStr = _toDateOnly(date);
    await _client.from(_table).upsert({
      'user_id': userId,
      'date': dateStr,
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
        .order('date', ascending: false)
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
        .gte('date', _toDateOnly(since))
        .order('date', ascending: true);
    return rows.map((r) => WeightLog.fromJson(r)).toList();
  }

  /// `YYYY-MM-DD` for Postgres `date` columns.
  static String _toDateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
