class Regimen {
  const Regimen({
    required this.id,
    required this.userId,
    required this.brand,
    this.generic,
    this.dose,
    this.form,
    this.frequency,
    this.indication,
    this.priorGlp1,
    this.supply,
    required this.startedAt,
    this.endedAt,
    required this.isActive,
  });

  final String id;
  final String userId;
  final String brand;
  final String? generic;
  final String? dose;
  final String? form; // injection | pill
  final String? frequency;
  final String? indication; // weight | t2d | both
  final String? priorGlp1; // naive | switched | restarted
  final String? supply; // branded | compounded
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool isActive;

  factory Regimen.fromJson(Map<String, dynamic> json) => Regimen(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    brand: json['brand'] as String,
    generic: json['generic'] as String?,
    dose: json['dose'] as String?,
    form: json['form'] as String?,
    frequency: json['frequency'] as String?,
    indication: json['indication'] as String?,
    priorGlp1: json['prior_glp1'] as String?,
    supply: json['supply'] as String?,
    startedAt: DateTime.parse(json['started_at'] as String),
    endedAt: json['ended_at'] != null
        ? DateTime.parse(json['ended_at'] as String)
        : null,
    isActive: json['is_active'] as bool,
  );
}
