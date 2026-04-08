import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_plan_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/coach_athlete_provider.dart';

class WorkoutPlanDetailScreen extends StatefulWidget {
  final String id;
  const WorkoutPlanDetailScreen({super.key, required this.id});

  @override
  State<WorkoutPlanDetailScreen> createState() =>
      _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutPlanProvider>().loadDetail(widget.id);
    });
  }

  void _showAssignDialog() async {
    final coachProv = context.read<CoachAthleteProvider>();
    if (coachProv.athletes.isEmpty) {
      await coachProv.loadAthletes();
    }

    if (!mounted) return;

    final athletes = coachProv.athletes;
    if (athletes.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Assign Plan'),
          content: const Text('No athletes found. Add athletes first.'),
          actions: [
            TextButton(onPressed: Navigator.of(context).pop, child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    String? selectedId;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Assign to Athlete'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Athlete',
              border: OutlineInputBorder(),
            ),
            items: athletes
                .map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text(a.fullName.isNotEmpty ? a.fullName : a.email),
                    ))
                .toList(),
            onChanged: (v) => setDialogState(() => selectedId = v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedId == null
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      final ok = await context
                          .read<WorkoutPlanProvider>()
                          .assign(widget.id, selectedId!);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Plan assigned!' : 'Failed to assign'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ));
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCoach = context.watch<AuthProvider>().user?.isCoach ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Detail'),
        actions: [
          if (isCoach)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Assign to athlete',
              onPressed: _showAssignDialog,
            ),
        ],
      ),
      body: Consumer<WorkoutPlanProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return Center(child: Text('Error: ${prov.error}'));
          }
          final plan = prov.detail;
          if (plan == null) return const Center(child: Text('Plan not found'));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(plan.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (plan.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(plan.description,
                    style: TextStyle(color: cs.onSurfaceVariant)),
              ],
              const SizedBox(height: 8),
              Text(
                '${plan.workouts.length} workout${plan.workouts.length == 1 ? '' : 's'}',
                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...plan.workouts.map((workout) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      initiallyExpanded: plan.workouts.length <= 3,
                      title: Text(workout.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${workout.exercises.length} exercise${workout.exercises.length == 1 ? '' : 's'}'),
                      children: workout.exercises.map((ex) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.fitness_center,
                                      size: 16, color: cs.primary),
                                  const SizedBox(width: 6),
                                  Text(ex.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Table(
                                defaultColumnWidth:
                                    const FlexColumnWidth(),
                                border: TableBorder.all(
                                  color: cs.outlineVariant.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(4)),
                                    ),
                                    children: ['Set', 'Reps', 'Weight (kg)']
                                        .map((h) => Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(h,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12)),
                                            ))
                                        .toList(),
                                  ),
                                  ...ex.sets.map((s) => TableRow(
                                        children: [
                                          s.setNumber,
                                          s.repetitions,
                                          s.weightKg,
                                        ]
                                            .map((v) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: Text('$v',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                ))
                                            .toList(),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
