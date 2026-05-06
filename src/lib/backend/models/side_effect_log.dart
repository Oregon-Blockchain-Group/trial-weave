class SideEffectLog {
  const SideEffectLog({
    required this.id,
    required this.userId,
    this.regimenId,
    required this.name,
    required this.severity,
    required this.loggedAt,
  });

  final String id;
  final String userId;
  final String? regimenId;
  final String name;
  final int severity;
  final DateTime loggedAt;

  factory SideEffectLog.fromJson(Map<String, dynamic> json) => SideEffectLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    regimenId: json['regimen_id'] as String?,
    name: json['name'] as String,
    severity: (json['severity'] as num).toInt(),
    loggedAt: DateTime.parse(json['logged_at'] as String),
  );
}
