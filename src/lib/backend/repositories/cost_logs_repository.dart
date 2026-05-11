import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cost_log.dart';

class CostLogsRepository {
  CostLogsRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'cost_logs';

  /// Upserts on the (user_id, month) composite PK. [month] should be the
  /// first day of the target month — this method normalizes it.
  Future<void> upsertForMonth({
    required DateTime month,
    required int amountUsd,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final firstOfMonth = DateTime.utc(month.year, month.month, 1);
    await _client.from(_table).upsert({
      'user_id': userId,
      'month': _toDateOnly(firstOfMonth),
      'amount_usd': amountUsd,
    });
  }

  /// Returns the User's cost log for the current calendar month, or null.
  Future<CostLog?> currentMonth() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final now = DateTime.now();
    final firstOfMonth = DateTime.utc(now.year, now.month, 1);
    final row = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('month', _toDateOnly(firstOfMonth))
        .maybeSingle();
    if (row == null) return null;
    return CostLog.fromJson(row);
  }

  static String _toDateOnly(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
