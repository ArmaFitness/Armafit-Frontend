import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/workout_session_provider.dart';

class WorkoutSessionDetailScreen extends StatefulWidget {
  final String id;
  const WorkoutSessionDetailScreen({super.key, required this.id});

  @override
  State<WorkoutSessionDetailScreen> createState() =>
      _WorkoutSessionDetailScreenState();
}

class _WorkoutSessionDetailScreenState
    extends State<WorkoutSessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutSessionProvider>().loadDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Session Detail')),
      body: Consumer<WorkoutSessionProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.error != null) {
            return Center(child: Text('Error: ${prov.error}'));
          }
          final s = prov.detail;
          if (s == null) return const Center(child: Text('Session not found'));

          // Group sets by exercise
          final Map<String, List<dynamic>> grouped = {};
          for (final set in s.sets) {
            final key = set.exerciseName ?? set.exerciseId ?? 'Unknown';
            grouped.putIfAbsent(key, () => []).add(set);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: cs.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEEE, MMM d yyyy  HH:mm')
                                .format(s.completedAt.toLocal()),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (s.workoutPlanTitle != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.list_alt, color: cs.secondary, size: 18),
                            const SizedBox(width: 8),
                            Text(s.workoutPlanTitle!),
                          ],
                        ),
                      ],
                      if (s.notes != null && s.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes, color: cs.tertiary, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.notes!)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.bar_chart, color: cs.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${s.sets.length} sets · ${grouped.length} exercises',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...grouped.entries.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fitness_center,
                                  size: 16, color: cs.primary),
                              const SizedBox(width: 6),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Table(
                            defaultColumnWidth: const FlexColumnWidth(),
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
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12)),
                                        ))
                                    .toList(),
                              ),
                              ...entry.value.map((set) => TableRow(
                                    children: [
                                      set.setNumber,
                                      set.repetitions,
                                      set.weightKg,
                                    ]
                                        .map((v) => Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text('$v',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12)),
                                            ))
                                        .toList(),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
