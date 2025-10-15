import 'package:ninerapp/domain/entities/person.dart';

class Parent extends Person {
  final String password;
  final String email;
  final double stars;

  Parent({
    super.id,
    required this.password,
    required this.email,
    required this.stars,
    required super.name,
    required super.lastName,
    required super.birthdate,
    required super.isFemale,
  });

  static Parent fromMap(Map<String, dynamic> map) {
    return Parent(
      id: map['id'] as int,
      password: map['password'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      lastName: map['last_name'] as String,
      birthdate: (map['birthdate'] as String?) == null ? null : DateTime.parse(map['birthdate'] as String),
      isFemale: map['is_female'] as bool,

      stars: (map['stars'] as num).toDouble(), // HACER, esto no va pero para de momento dejar algo
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'password': password,
      'email': email,
      'stars': stars,
    });
  }
}