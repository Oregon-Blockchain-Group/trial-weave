/// Snapshot of which research / cohort / marketing grants the User agreed to,
/// at a given consent text version. The full grants payload lands in the
/// `grants` jsonb column.
class Consent {
  const Consent({
    required this.id,
    required this.userId,
    required this.version,
    required this.grants,
    required this.grantedAt,
  });

  final String id;
  final String userId;
  final String version;
  final Map<String, dynamic> grants;
  final DateTime grantedAt;

  factory Consent.fromJson(Map<String, dynamic> json) => Consent(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    version: json['version'] as String,
    grants: Map<String, dynamic>.from(json['grants'] as Map),
    grantedAt: DateTime.parse(json['granted_at'] as String),
  );
}
