import 'package:ninerapp/domain/entities/person.dart';

class Parent extends Person {
  final String? password;
  final String email;
  final int rating;
  final int amountRatings;
  final int amountReports;

  Parent({
    super.id,
    required this.password,
    required this.email,
    
    required super.name,
    required super.lastName,
    required super.birthdate,
    required super.isFemale,
    required super.lastLatitude,
    required super.lastLongitude,
    required this.rating,
    required this.amountRatings,
    required this.amountReports,
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

      lastLatitude: null,
      lastLongitude: null,
      rating: (map['rating'] as num).toInt(),
      amountRatings: (map['amount_ratings'] as num).toInt(),
      amountReports: (map['amount_reports'] as num).toInt(),
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
      'rating': rating,
      'amount_ratings': amountRatings,
      'amount_reports': amountReports,
    });
  }
}