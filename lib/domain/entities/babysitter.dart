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
    );
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
    });
  }

  int getExperienceYears() {
    if (workStartYear == null) return 0;
    final currentYear = DateTime.now().year;
    return currentYear - workStartYear!;
  }
}