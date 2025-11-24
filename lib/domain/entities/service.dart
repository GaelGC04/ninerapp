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
  final bool deletedByParent;
  final bool deletedByBabysitter;
  bool ratedByParent;
  bool ratedByBabysitter;
  bool reportedByParent;
  bool reportedByBabysitter;

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
    required this.deletedByParent,
    required this.deletedByBabysitter,
    required this.ratedByParent,
    required this.ratedByBabysitter,
    required this.reportedByParent,
    required this.reportedByBabysitter,
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
      latitude: double.parse(map['latitude']),
      longitude: double.parse(map['longitude']),
      instructions: map['instructions'] as String?,
      ratedByParent: map['rated_by_parent'] as bool,
      ratedByBabysitter: map['rated_by_babysitter'] as bool,
      deletedByParent: map['deleted_by_parent'] as bool,
      deletedByBabysitter: map['deleted_by_babysitter'] as bool,
      children: list,
      reportedByParent: map['reported_by_parent'] as bool,
      reportedByBabysitter: map['reported_by_babysitter'] as bool,
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
      'deleted_by_parent': deletedByParent,
      'deleted_by_babysitter': deletedByBabysitter,
      'rated_by_parent': ratedByParent,
      'rated_by_babysitter': ratedByBabysitter,
      'reported_by_parent': reportedByParent,
      'reported_by_babysitter': reportedByBabysitter,
    };
  }
}