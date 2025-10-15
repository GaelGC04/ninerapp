class Person {
  int? id;
  final String name;
  final String lastName;
  final DateTime? birthdate;
  final bool isFemale;

  Person({
    this.id,
    required this.name,
    required this.lastName,
    required this.birthdate,
    required this.isFemale,
  });

  int? getAge() {
    if (birthdate == null) {
      return null;
    }

    final currentDate = DateTime.now();
    int age = currentDate.year - birthdate!.year;
    if (currentDate.month < birthdate!.month || (currentDate.month == birthdate!.month && currentDate.day < birthdate!.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'last_name': lastName,
      'birthdate': birthdate ?? birthdate?.toIso8601String(),
      'is_female': isFemale,
    };
  }
}