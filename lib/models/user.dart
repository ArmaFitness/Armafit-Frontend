class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final bool isAthlete;
  final bool isCoach;

  const User({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.isAthlete,
    required this.isCoach,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id']?.toString() ?? '',
        name: j['name'] ?? '',
        surname: j['surname'] ?? '',
        email: j['email'] ?? '',
        isAthlete: j['isAthlete'] ?? false,
        isCoach: j['isCoach'] ?? false,
      );

  String get fullName => '$name $surname'.trim();
}
