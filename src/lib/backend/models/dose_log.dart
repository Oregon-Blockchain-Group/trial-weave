class DoseLog {
  const DoseLog({
    required this.id,
    required this.userId,
    required this.regimenId,
    required this.takenAt,
    this.notes,
  });

  final String id;
  final String userId;
  final String regimenId;
  final DateTime takenAt;
  final String? notes;

  factory DoseLog.fromJson(Map<String, dynamic> json) => DoseLog(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    regimenId: json['regimen_id'] as String,
    takenAt: DateTime.parse(json['taken_at'] as String),
    notes: json['notes'] as String?,
  );
}
