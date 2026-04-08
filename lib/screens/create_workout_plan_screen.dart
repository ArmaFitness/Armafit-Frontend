import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_plan.dart';
import '../providers/workout_plan_provider.dart';

class CreateWorkoutPlanScreen extends StatefulWidget {
  const CreateWorkoutPlanScreen({super.key});

  @override
  State<CreateWorkoutPlanScreen> createState() =>
      _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState extends State<CreateWorkoutPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  // Mutable workout data
  final List<_WorkoutDraft> _workouts = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _addWorkout() {
    setState(() {
      _workouts.add(_WorkoutDraft(
        nameCtrl: TextEditingController(),
        exercises: [],
      ));
    });
  }

  void _removeWorkout(int i) {
    setState(() {
      _workouts[i].dispose();
      _workouts.removeAt(i);
    });
  }

  void _addExercise(int wi) {
    setState(() {
      _workouts[wi].exercises.add(_ExerciseDraft(
        nameCtrl: TextEditingController(),
        sets: [_SetDraft()],
      ));
    });
  }

  void _removeExercise(int wi, int ei) {
    setState(() {
      _workouts[wi].exercises[ei].dispose();
      _workouts[wi].exercises.removeAt(ei);
    });
  }

  void _addSet(int wi, int ei) {
    final nextNum = _workouts[wi].exercises[ei].sets.length + 1;
    setState(() {
      _workouts[wi].exercises[ei].sets.add(_SetDraft(setNumber: nextNum));
    });
  }

  void _removeSet(int wi, int ei, int si) {
    setState(() {
      _workouts[wi].exercises[ei].sets[si].dispose();
      _workouts[wi].exercises[ei].sets.removeAt(si);
      // Renumber
      for (var k = 0; k < _workouts[wi].exercises[ei].sets.length; k++) {
        _workouts[wi].exercises[ei].sets[k].setNumberCtrl.text = '${k + 1}';
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one workout day')),
      );
      return;
    }

    setState(() => _saving = true);

    final workouts = _workouts.asMap().entries.map((we) {
      final wi = we.key;
      final w = we.value;
      return PlanWorkout(
        name: w.nameCtrl.text.trim(),
        orderIndex: wi,
        exercises: w.exercises.asMap().entries.map((ee) {
          final ei = ee.key;
          final e = ee.value;
          return PlanExercise(
            name: e.nameCtrl.text.trim(),
            orderIndex: ei,
            sets: e.sets.asMap().entries.map((se) {
              final s = se.value;
              return PlanSet(
                setNumber: int.tryParse(s.setNumberCtrl.text) ?? (se.key + 1),
                repetitions: int.tryParse(s.repsCtrl.text) ?? 0,
                weightKg: double.tryParse(s.weightCtrl.text) ?? 0,
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();

    final plan = WorkoutPlan(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      workouts: workouts,
    );

    final ok = await context.read<WorkoutPlanProvider>().create(plan);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<WorkoutPlanProvider>().error ?? 'Error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Workout Plan'),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.check),
                  tooltip: 'Save',
                  onPressed: _save,
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Plan Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workout Days',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: _addWorkout,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Day'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._workouts.asMap().entries.map((we) {
              final wi = we.key;
              final w = we.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: w.nameCtrl,
                              decoration: InputDecoration(
                                labelText: 'Day ${wi + 1} Name',
                                hintText: 'e.g. Push Day',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: cs.error,
                            onPressed: () => _removeWorkout(wi),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...w.exercises.asMap().entries.map((ee) {
                        final ei = ee.key;
                        final ex = ee.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: cs.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: ex.nameCtrl,
                                        decoration: InputDecoration(
                                          labelText: 'Exercise ${ei + 1}',
                                          hintText: 'e.g. Bench Press',
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                        validator: (v) =>
                                            v == null || v.trim().isEmpty
                                                ? 'Required'
                                                : null,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      color: cs.error,
                                      onPressed: () => _removeExercise(wi, ei),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Sets',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurfaceVariant)),
                                    const Spacer(),
                                    TextButton.icon(
                                      onPressed: () => _addSet(wi, ei),
                                      icon: const Icon(Icons.add, size: 14),
                                      label: const Text('Add Set',
                                          style: TextStyle(fontSize: 12)),
                                      style: TextButton.styleFrom(
                                          visualDensity: VisualDensity.compact),
                                    ),
                                  ],
                                ),
                                ...ex.sets.asMap().entries.map((se) {
                                  final si = se.key;
                                  final s = se.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: Text(
                                            'S${si + 1}',
                                            style: TextStyle(
                                                color: cs.primary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: s.repsCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Reps',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: s.weightCtrl,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
                                            decoration: const InputDecoration(
                                              labelText: 'kg',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            validator: (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Required'
                                                    : null,
                                          ),
                                        ),
                                        if (ex.sets.length > 1)
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline,
                                                size: 18),
                                            onPressed: () =>
                                                _removeSet(wi, ei, si),
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () => _addExercise(wi),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_workouts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No workout days yet',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _WorkoutDraft {
  final TextEditingController nameCtrl;
  final List<_ExerciseDraft> exercises;

  _WorkoutDraft({required this.nameCtrl, required this.exercises});

  void dispose() {
    nameCtrl.dispose();
    for (final e in exercises) {
      e.dispose();
    }
  }
}

class _ExerciseDraft {
  final TextEditingController nameCtrl;
  final List<_SetDraft> sets;

  _ExerciseDraft({required this.nameCtrl, required this.sets});

  void dispose() {
    nameCtrl.dispose();
    for (final s in sets) {
      s.dispose();
    }
  }
}

class _SetDraft {
  final TextEditingController setNumberCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;

  _SetDraft({int setNumber = 1})
      : setNumberCtrl = TextEditingController(text: '$setNumber'),
        repsCtrl = TextEditingController(),
        weightCtrl = TextEditingController();

  void dispose() {
    setNumberCtrl.dispose();
    repsCtrl.dispose();
    weightCtrl.dispose();
  }
}
