class FactorLog {
  const FactorLog({
    required this.id,
    required this.userId,
    required this.factorKey,
    required this.rating,
    required this.isBaseline,
    required this.loggedAt,
  });

  final String id;
  final String userId;
  final String factorKey;
  final int rating;
  final bool isBaseline;
  final DateTime loggedAt;

  factory FactorLog.fromJson(Map<String, dynamic> json) => FactorLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    factorKey: json['factor_key'] as String,
    rating: (json['rating'] as num).toInt(),
    isBaseline: json['is_baseline'] as bool,
    loggedAt: DateTime.parse(json['logged_at'] as String),
  );
}
