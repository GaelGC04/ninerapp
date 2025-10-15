import 'package:ninerapp/domain/entities/person.dart';

class Child extends Person {
  final bool physicalDisability;
  final bool hearingDisability;
  final bool visualDisability;
  final String? otherDisabilities;

  Child({
    super.id,
    required super.name,
    required super.lastName,
    required super.birthdate,
    required super.isFemale,
    required this.physicalDisability,
    required this.hearingDisability,
    required this.visualDisability,
    this.otherDisabilities,
  });

  static Child fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'] as int,
      name: map['name'] as String,
      lastName: map['last_name'] as String,
      birthdate: DateTime.parse(map['birthdate'] as String),
      isFemale: map['is_female'] as bool,
      physicalDisability: map['physical_disability'] as bool,
      hearingDisability: map['hearing_disability'] as bool,
      visualDisability: map['visual_disability'] as bool,
      otherDisabilities: map['other_disability'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'physical_disability': physicalDisability,
      'hearing_disability': hearingDisability,
      'visual_disability': visualDisability,
      'other_disabilities': otherDisabilities,
    });
  }

  @override
  int getAge() {
    int age = super.getAge()!;
    if (age == 0) {
      final currentDate = DateTime.now();
      int age = currentDate.month - birthdate!.month;
      if (currentDate.day < birthdate!.day) {
        age--;
      }
      return age * -1;
    }
    return age;
  }
}