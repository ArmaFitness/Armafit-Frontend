class CoachAthleteUser {
  final String id;
  final String name;
  final String surname;
  final String email;

  const CoachAthleteUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
  });

  factory CoachAthleteUser.fromJson(Map<String, dynamic> j) => CoachAthleteUser(
        id: j['id']?.toString() ?? '',
        name: j['name'] ?? '',
        surname: j['surname'] ?? '',
        email: j['email'] ?? '',
      );

  String get fullName => '$name $surname'.trim();
}
