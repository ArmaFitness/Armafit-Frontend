class PlanSet {
  final String? id;
  final int setNumber;
  final int repetitions;
  final double weightKg;

  const PlanSet({
    this.id,
    required this.setNumber,
    required this.repetitions,
    required this.weightKg,
  });

  factory PlanSet.fromJson(Map<String, dynamic> j) => PlanSet(
        id: j['id']?.toString(),
        setNumber: j['setNumber'] ?? 0,
        repetitions: j['repetitions'] ?? 0,
        weightKg: (j['weightKg'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'repetitions': repetitions,
        'weightKg': weightKg,
      };
}

class PlanExercise {
  final String? id;
  final String name;
  final int orderIndex;
  final List<PlanSet> sets;

  const PlanExercise({
    this.id,
    required this.name,
    required this.orderIndex,
    required this.sets,
  });

  factory PlanExercise.fromJson(Map<String, dynamic> j) => PlanExercise(
        id: j['id']?.toString(),
        name: j['name'] ?? '',
        orderIndex: j['orderIndex'] ?? 0,
        sets:
            (j['sets'] as List? ?? []).map((s) => PlanSet.fromJson(s)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'orderIndex': orderIndex,
        'sets': sets.map((s) => s.toJson()).toList(),
      };
}

class PlanWorkout {
  final String? id;
  final String name;
  final int orderIndex;
  final List<PlanExercise> exercises;

  const PlanWorkout({
    this.id,
    required this.name,
    required this.orderIndex,
    required this.exercises,
  });

  factory PlanWorkout.fromJson(Map<String, dynamic> j) => PlanWorkout(
        id: j['id']?.toString(),
        name: j['name'] ?? '',
        orderIndex: j['orderIndex'] ?? 0,
        exercises: (j['exercises'] as List? ?? [])
            .map((e) => PlanExercise.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'orderIndex': orderIndex,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}

class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  final List<PlanWorkout> workouts;
  final DateTime? createdAt;

  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.workouts,
    this.createdAt,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
        id: j['id']?.toString() ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        workouts: (j['workouts'] as List? ?? [])
            .map((w) => PlanWorkout.fromJson(w))
            .toList(),
        createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
      );
}
