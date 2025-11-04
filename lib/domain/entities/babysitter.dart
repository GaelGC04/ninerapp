import 'package:ninerapp/domain/entities/person.dart';

class Babysitter extends Person {
  final String password;
  final String email;
  final double pricePerHour;
  final int? workStartYear;
  final bool expPhysicalDisability;
  final bool expHearingDisability;
  final bool expVisualDisability;
  final String? expOtherDisabilities;
  final double rating;
  final double amountRatings;

  late int? distanceMeters;
  late bool isFavorite;

  Babysitter({
    super.id,
    required this.password,
    required this.email,
    required super.name,
    required super.lastName,
    required super.birthdate,
    required super.isFemale,
    required this.pricePerHour,
    required this.workStartYear,
    required this.expPhysicalDisability,
    required this.expHearingDisability,
    required this.expVisualDisability,
    this.expOtherDisabilities,
    required super.lastLatitude,
    required super.lastLongitude,
    required this.rating,
    required this.amountRatings,
    this.distanceMeters,

    this.isFavorite = false,
  });

  static Babysitter fromMap(Map<String, dynamic> map) {
    return Babysitter(
      id: map['id'] as int,
      password: map['password'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      lastName: map['last_name'] as String,
      birthdate: (map['birthdate'] as String?) == null ? null : DateTime.parse(map['birthdate'] as String),
      isFemale: map['is_female'] as bool,

      pricePerHour: (map['price_per_hour'] as num).toDouble(),
      workStartYear: map['work_start_year'] as int?,
      expPhysicalDisability: map['exp_physical_disability'] as bool,
      expHearingDisability: map['exp_hearing_disability'] as bool,
      expVisualDisability: map['exp_visual_disability'] as bool,
      expOtherDisabilities: map['exp_other_disabilities'] as String?,
      lastLatitude: map['last_latitude'] == null ? null : double.parse(map['last_latitude']),
      lastLongitude: map['last_latitude'] == null ? null : double.parse(map['last_longitude']),
      rating: (map['rating'] as num).toDouble(),
      amountRatings: (map['amount_ratings'] as num).toDouble(),
    );
  }

  double getAverageStars() {
    if (amountRatings == 0) return 0;
    return (rating / amountRatings);
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'password': password,
      'email': email,
      'price_per_hour': pricePerHour,
      'exp_physical_disability': expPhysicalDisability,
      'exp_hearing_disability': expHearingDisability,
      'exp_visual_disability': expVisualDisability,
      'exp_other_disabilities': expOtherDisabilities,
      'last_latitude': lastLatitude,
      'last_longitude': lastLongitude,
      'rating': rating,
      'amount_ratings': amountRatings,
    });
  }

  int getExperienceYears() {
    if (workStartYear == null) return 0;
    final currentYear = DateTime.now().year;
    return currentYear - workStartYear!;
  }
}