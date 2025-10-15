import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';

class Service {
  final int? id;
  late List<Child> children;
  final Parent parent;
  final Babysitter babysitter;
  final bool paymentWithCard;
  final DateTime date;
  final int hours;
  final int minutes;
  final double totalPrice;
  final String status;
  final double latitude;
  final double longitude;
  final String? instructions;

  Service({
    this.id,
    this.children = const [],
    required this.parent,
    required this.babysitter,
    required this.paymentWithCard,
    required this.date,
    required this.hours,
    required this.minutes,
    required this.totalPrice,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.instructions,
  });

  static Service fromMap(Map<String, dynamic> map, List<Child> list) {
    return Service(
      id: map['id'] as int,
      parent: Parent.fromMap(map['parent'] as Map<String, dynamic>),
      babysitter: Babysitter.fromMap(map['babysitter'] as Map<String, dynamic>),
      paymentWithCard: map['payment_with_card'] as bool,
      date: DateTime.parse(map['date'] as String),
      hours: map['hours'] as int,
      minutes: map['minutes'] as int,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: map['status'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      instructions: map['instructions'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent_id': parent.id,
      'babysitter_id': babysitter.id,
      'payment_with_card': paymentWithCard,
      'date': date.toIso8601String(),
      'hours': hours,
      'minutes': minutes,
      'total_price': totalPrice,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'instructions': instructions,
    };
  }
}