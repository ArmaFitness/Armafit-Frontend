class SessionSet {
  final String? id;
  final String? exerciseId;
  final String? exerciseName;
  final int setNumber;
  final int repetitions;
  final double weightKg;

  const SessionSet({
    this.id,
    this.exerciseId,
    this.exerciseName,
    required this.setNumber,
    required this.repetitions,
    required this.weightKg,
  });

  factory SessionSet.fromJson(Map<String, dynamic> j) => SessionSet(
        id: j['id']?.toString(),
        exerciseId: j['exerciseId']?.toString(),
        exerciseName: j['exerciseName'] ?? j['exercise']?['name'],
        setNumber: j['setNumber'] ?? 0,
        repetitions: j['repetitions'] ?? 0,
        weightKg: (j['weightKg'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'setNumber': setNumber,
      'repetitions': repetitions,
      'weightKg': weightKg,
    };
    if (exerciseId != null) m['exerciseId'] = exerciseId;
    if (exerciseName != null) m['exerciseName'] = exerciseName;
    return m;
  }
}

class WorkoutSession {
  final String id;
  final String? workoutPlanId;
  final String? workoutPlanTitle;
  final String? notes;
  final DateTime completedAt;
  final List<SessionSet> sets;

  const WorkoutSession({
    required this.id,
    this.workoutPlanId,
    this.workoutPlanTitle,
    this.notes,
    required this.completedAt,
    required this.sets,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> j) => WorkoutSession(
        id: j['id']?.toString() ?? '',
        workoutPlanId: j['workoutPlanId']?.toString(),
        workoutPlanTitle: j['workoutPlan']?['title'] ?? j['workoutPlanTitle'],
        notes: j['notes'],
        completedAt: DateTime.tryParse(
                j['completedAt'] ?? j['createdAt'] ?? '') ??
            DateTime.now(),
        sets: (j['sets'] as List? ?? [])
            .map((s) => SessionSet.fromJson(s))
            .toList(),
      );
}
