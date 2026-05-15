class WeightLog {
  const WeightLog({
    required this.id,
    required this.userId,
    required this.loggedAt,
    required this.date,
    required this.weightLb,
  });

  final String id;
  final String userId;
  final DateTime loggedAt;
  final DateTime date;
  final double weightLb;

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    loggedAt: DateTime.parse(json['logged_at'] as String),
    date: DateTime.parse(json['date'] as String),
    weightLb: (json['weight_lb'] as num).toDouble(),
  );
}
