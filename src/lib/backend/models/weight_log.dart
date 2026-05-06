class WeightLog {
  const WeightLog({
    required this.userId,
    required this.date,
    required this.weightLb,
  });

  final String userId;
  final DateTime date;
  final double weightLb;

  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
    userId: json['user_id'] as String,
    date: DateTime.parse(json['date'] as String),
    weightLb: (json['weight_lb'] as num).toDouble(),
  );
}
