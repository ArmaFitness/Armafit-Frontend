import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_session.dart';
import '../models/workout_plan.dart';
import '../providers/workout_session_provider.dart';
import '../providers/workout_plan_provider.dart';

class LogSessionScreen extends StatefulWidget {
  const LogSessionScreen({super.key});

  @override
  State<LogSessionScreen> createState() => _LogSessionScreenState();
}

class _LogSessionScreenState extends State<LogSessionScreen> {
  final _notesCtrl = TextEditingController();
  WorkoutPlan? _selectedPlan;
  bool _saving = false;
  final List<_SetRow> _sets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutPlanProvider>().load();
    });
    _addSet();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final s in _sets) {
      s.dispose();
    }
    super.dispose();
  }

  void _addSet() {
    setState(() {
      final num = _sets.length + 1;
      _sets.add(_SetRow(setNumber: num));
    });
  }

  void _removeSet(int i) {
    setState(() {
      _sets[i].dispose();
      _sets.removeAt(i);
      for (var k = 0; k < _sets.length; k++) {
        _sets[k].setNumberCtrl.text = '${k + 1}';
      }
    });
  }

  void _onPlanSelected(WorkoutPlan? plan) {
    setState(() {
      _selectedPlan = plan;
      _sets.clear();
      if (plan != null) {
        // Pre-fill sets from the plan
        int globalSet = 1;
        for (final workout in plan.workouts) {
          for (final exercise in workout.exercises) {
            for (final s in exercise.sets) {
              _sets.add(_SetRow(
                setNumber: globalSet++,
                exerciseName: exercise.name,
                exerciseId: exercise.id,
                reps: s.repetitions,
                weight: s.weightKg,
              ));
            }
          }
        }
      }
      if (_sets.isEmpty) _addSet();
    });
  }

  Future<void> _save() async {
    final hasSets = _sets.every((s) =>
        s.exerciseNameCtrl.text.isNotEmpty &&
        s.repsCtrl.text.isNotEmpty &&
        s.weightCtrl.text.isNotEmpty);
    if (!hasSets) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all set fields')),
      );
      return;
    }

    setState(() => _saving = true);

    final sets = _sets.asMap().entries.map((e) {
      final s = e.value;
      return SessionSet(
        exerciseName: s.exerciseNameCtrl.text.trim(),
        exerciseId: s.exerciseId,
        setNumber: int.tryParse(s.setNumberCtrl.text) ?? (e.key + 1),
        repetitions: int.tryParse(s.repsCtrl.text) ?? 0,
        weightKg: double.tryParse(s.weightCtrl.text) ?? 0,
      );
    }).toList();

    final ok = await context.read<WorkoutSessionProvider>().logSession(
          workoutPlanId: _selectedPlan?.id,
          notes: _notesCtrl.text.trim(),
          sets: sets,
        );

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(context.read<WorkoutSessionProvider>().error ?? 'Error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final plans = context.watch<WorkoutPlanProvider>().plans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Session'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<WorkoutPlan?>(
            value: _selectedPlan,
            decoration: const InputDecoration(
              labelText: 'Workout Plan (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.list_alt_outlined),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('No plan')),
              ...plans.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.title, overflow: TextOverflow.ellipsis),
                  )),
            ],
            onChanged: _onPlanSelected,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sets',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              FilledButton.icon(
                onPressed: _addSet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Set'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._sets.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: cs.primaryContainer,
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  fontSize: 12, color: cs.onPrimaryContainer)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: s.exerciseNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Exercise',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_sets.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeSet(i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: s.repsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: s.weightCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SetRow {
  final TextEditingController setNumberCtrl;
  final TextEditingController exerciseNameCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;
  final String? exerciseId;

  _SetRow({
    required int setNumber,
    String? exerciseName,
    this.exerciseId,
    int? reps,
    double? weight,
  })  : setNumberCtrl = TextEditingController(text: '$setNumber'),
        exerciseNameCtrl =
            TextEditingController(text: exerciseName ?? ''),
        repsCtrl =
            TextEditingController(text: reps != null ? '$reps' : ''),
        weightCtrl = TextEditingController(
            text: weight != null ? '$weight' : '');

  void dispose() {
    setNumberCtrl.dispose();
    exerciseNameCtrl.dispose();
    repsCtrl.dispose();
    weightCtrl.dispose();
  }
}
