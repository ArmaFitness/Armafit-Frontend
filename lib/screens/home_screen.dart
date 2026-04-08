import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/weight_provider.dart';
import '../providers/workout_plan_provider.dart';
import '../providers/workout_session_provider.dart';
import 'weight_screen.dart';
import 'coach_athlete_screen.dart';
import 'conversations_screen.dart';
import 'workout_plan_detail_screen.dart';
import 'create_workout_plan_screen.dart';
import 'workout_session_detail_screen.dart';
import 'log_session_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    _DashboardPage(),
    WeightScreen(),
    _WorkoutsPage(),
    CoachAthleteScreen(),
    ConversationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_weight_outlined),
            selectedIcon: Icon(Icons.monitor_weight),
            label: 'Weight',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Team',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}

// ─── Dashboard ───────────────────────────────────────────────────────────────

class _DashboardPage extends StatefulWidget {
  const _DashboardPage();

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        context.read<WeightProvider>().load();
        context.read<WorkoutPlanProvider>().load();
        context.read<WorkoutSessionProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final weightProv = context.watch<WeightProvider>();
    final planProv = context.watch<WorkoutPlanProvider>();
    final sessionProv = context.watch<WorkoutSessionProvider>();

    final greeting = _greeting();
    final latestWeight = weightProv.entries.isNotEmpty ? weightProv.entries.first : null;
    final recentSessions = sessionProv.sessions.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArmaFit'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<WeightProvider>().load(),
            context.read<WorkoutPlanProvider>().load(),
            context.read<WorkoutSessionProvider>().load(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Hero card
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting,
                              style: TextStyle(color: cs.onPrimaryContainer)),
                          const SizedBox(height: 4),
                          Text(
                            user?.name.isNotEmpty == true
                                ? user!.name
                                : 'Athlete',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.bold),
                          ),
                          if (user?.isCoach == true && user?.isAthlete == true)
                            Text('Athlete & Coach',
                                style: TextStyle(
                                    color:
                                        cs.onPrimaryContainer.withOpacity(0.8)))
                          else if (user?.isCoach == true)
                            Text('Coach',
                                style: TextStyle(
                                    color:
                                        cs.onPrimaryContainer.withOpacity(0.8)))
                          else
                            Text('Athlete',
                                style: TextStyle(
                                    color:
                                        cs.onPrimaryContainer.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    Icon(Icons.fitness_center,
                        size: 48, color: cs.onPrimaryContainer.withOpacity(0.4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.monitor_weight,
                    label: 'Latest Weight',
                    value: latestWeight != null
                        ? '${latestWeight.weightKg.toStringAsFixed(1)} kg'
                        : '—',
                    color: cs.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.list_alt,
                    label: 'Plans',
                    value: '${planProv.plans.length}',
                    color: cs.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Sessions',
                    value: '${sessionProv.sessions.length}',
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recent sessions
            if (recentSessions.isNotEmpty) ...[
              Text('Recent Sessions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...recentSessions.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Icon(Icons.fitness_center,
                            color: cs.onPrimaryContainer, size: 20),
                      ),
                      title: Text(
                          s.workoutPlanTitle ??
                              DateFormat('MMM d').format(s.completedAt.toLocal()),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        DateFormat('EEE, MMM d · HH:mm')
                            .format(s.completedAt.toLocal()),
                      ),
                      trailing: Text('${s.sets.length} sets',
                          style: TextStyle(color: cs.primary)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkoutSessionDetailScreen(id: s.id),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
            ],

            // Quick actions
            Text('Quick Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_chart,
                    label: 'Log Session',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LogSessionScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_box_outlined,
                    label: 'New Plan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const CreateWorkoutPlanScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 32),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Workouts (Plans + Sessions tabs) ────────────────────────────────────────

class _WorkoutsPage extends StatefulWidget {
  const _WorkoutsPage();

  @override
  State<_WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<_WorkoutsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutPlanProvider>().load();
      context.read<WorkoutSessionProvider>().load();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt_outlined), text: 'Plans'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'Sessions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [_PlansTab(), _SessionsTab()],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tab,
        builder: (_, __) => FloatingActionButton.extended(
          heroTag: 'workouts_fab',
          onPressed: () async {
            final tabIndex = _tab.index;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => tabIndex == 0
                    ? const CreateWorkoutPlanScreen()
                    : const LogSessionScreen(),
              ),
            );
            if (!context.mounted) return;
            if (tabIndex == 0) {
              context.read<WorkoutPlanProvider>().load();
            } else {
              context.read<WorkoutSessionProvider>().load();
            }
          },
          icon: const Icon(Icons.add),
          label: Text(_tab.index == 0 ? 'New Plan' : 'Log Session'),
        ),
      ),
    );
  }
}

class _PlansTab extends StatelessWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<WorkoutPlanProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading && prov.plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prov.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.list_alt_outlined,
                    size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                const Text('No workout plans yet'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: prov.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: prov.plans.length,
            itemBuilder: (_, i) {
              final p = prov.plans[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.list_alt,
                        color: cs.onPrimaryContainer, size: 20),
                  ),
                  title: Text(p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.description.isNotEmpty)
                        Text(p.description,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                          '${p.workouts.length} workout${p.workouts.length == 1 ? '' : 's'}',
                          style: TextStyle(
                              color: cs.primary, fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutPlanDetailScreen(id: p.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<WorkoutSessionProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading && prov.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prov.sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                const Text('No sessions logged yet'),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: prov.load,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: prov.sessions.length,
            itemBuilder: (_, i) {
              final s = prov.sessions[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: cs.secondaryContainer,
                    child: Icon(Icons.fitness_center,
                        color: cs.onSecondaryContainer, size: 20),
                  ),
                  title: Text(
                    s.workoutPlanTitle ??
                        DateFormat('MMM d, yyyy')
                            .format(s.completedAt.toLocal()),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('EEE, MMM d · HH:mm')
                        .format(s.completedAt.toLocal()),
                  ),
                  trailing: Chip(
                    label: Text('${s.sets.length} sets'),
                    visualDensity: VisualDensity.compact,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkoutSessionDetailScreen(id: s.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
