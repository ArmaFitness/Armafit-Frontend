import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weight_entry.dart';
import '../providers/weight_provider.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightProvider>().load();
    });
  }

  void _showAddDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final val = double.tryParse(ctrl.text);
              if (val == null || val <= 0) return;
              Navigator.pop(ctx);
              final ok = await context.read<WeightProvider>().log(val);
              if (!mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<WeightProvider>().error ?? 'Error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bodyweight'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeightProvider>().load(),
          ),
        ],
      ),
      body: Consumer<WeightProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monitor_weight_outlined,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text('No weight entries yet'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Log weight'),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              if (prov.entries.length >= 2)
                _WeightChart(entries: prov.entries.reversed.toList()),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.entries.length,
                  itemBuilder: (_, i) {
                    final e = prov.entries[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${e.weightKg.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '${e.weightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy  HH:mm').format(e.loggedAt.toLocal()),
                        ),
                        trailing: i == 0 && prov.entries.length > 1
                            ? _DeltaBadge(
                                current: e.weightKg,
                                previous: prov.entries[1].weightKg,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Log Weight'),
      ),
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  final double current;
  final double previous;
  const _DeltaBadge({required this.current, required this.previous});

  @override
  Widget build(BuildContext context) {
    final delta = current - previous;
    final color = delta > 0 ? Colors.red : Colors.green;
    final icon = delta > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    if (delta == 0) return const SizedBox.shrink();
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(
        '${delta.abs().toStringAsFixed(1)} kg',
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  const _WeightChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final recent = entries.length > 10 ? entries.sublist(entries.length - 10) : entries;
    final spots = recent
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg))
        .toList();
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 24, 8),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            horizontalInterval: 2,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: cs.outlineVariant.withOpacity(0.4), strokeWidth: 1),
            getDrawingVerticalLine: (_) =>
                FlLine(color: cs.outlineVariant.withOpacity(0.2), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                ),
              ),
            ),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: cs.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: cs.primary,
                  strokeWidth: 2,
                  strokeColor: cs.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: cs.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
