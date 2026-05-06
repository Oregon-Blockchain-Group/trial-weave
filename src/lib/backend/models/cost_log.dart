class CostLog {
  const CostLog({
    required this.userId,
    required this.month,
    required this.amountUsd,
  });

  final String userId;

  /// First of the month (date column in Postgres).
  final DateTime month;

  final int amountUsd;

  factory CostLog.fromJson(Map<String, dynamic> json) => CostLog(
    userId: json['user_id'] as String,
    month: DateTime.parse(json['month'] as String),
    amountUsd: (json['amount_usd'] as num).toInt(),
  );
}
