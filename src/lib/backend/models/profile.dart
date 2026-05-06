class Profile {
  const Profile({
    required this.userId,
    this.age,
    this.sex,
    this.raceEthnicity,
    this.city,
    this.state,
    this.heightFeet,
    this.heightInches,
    this.startingWeightLb,
  });

  final String userId;
  final int? age;
  final String? sex;
  final String? raceEthnicity;
  final String? city;
  final String? state;
  final int? heightFeet;
  final int? heightInches;
  final double? startingWeightLb;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    userId: json['user_id'] as String,
    age: json['age'] as int?,
    sex: json['sex'] as String?,
    raceEthnicity: json['race_ethnicity'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    heightFeet: json['height_feet'] as int?,
    heightInches: json['height_inches'] as int?,
    startingWeightLb: (json['starting_weight_lb'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'age': age,
    'sex': sex,
    'race_ethnicity': raceEthnicity,
    'city': city,
    'state': state,
    'height_feet': heightFeet,
    'height_inches': heightInches,
    'starting_weight_lb': startingWeightLb,
  };
}
