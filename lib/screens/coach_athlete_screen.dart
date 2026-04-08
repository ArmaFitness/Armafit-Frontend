import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/coach_athlete_provider.dart';
import '../providers/message_provider.dart';
import '../models/coach_athlete.dart';

class CoachAthleteScreen extends StatefulWidget {
  const CoachAthleteScreen({super.key});

  @override
  State<CoachAthleteScreen> createState() => _CoachAthleteScreenState();
}

class _CoachAthleteScreenState extends State<CoachAthleteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final user = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>().user;
    final isCoach = auth?.isCoach ?? false;
    final isAthlete = auth?.isAthlete ?? false;
    final tabCount = (isCoach ? 1 : 0) + (isAthlete ? 1 : 0);
    _tabCtrl = TabController(length: tabCount < 1 ? 1 : tabCount, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<CoachAthleteProvider>();
      if (isCoach) prov.loadAthletes();
      if (isAthlete) prov.loadCoaches();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog(bool isAddingAthlete) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAddingAthlete ? 'Add Athlete' : 'Request Coach'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isAddingAthlete ? 'Athlete Email' : 'Coach Email',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = ctrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final prov = context.read<CoachAthleteProvider>();
              final ok = isAddingAthlete
                  ? await prov.assignAthlete(email)
                  : await prov.assignCoach(email);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? isAddingAthlete
                        ? 'Athlete added!'
                        : 'Coach requested!'
                    : prov.error ?? 'Error'),
                backgroundColor: ok ? Colors.green : Colors.red,
              ));
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>().user;
    final isCoach = auth?.isCoach ?? false;
    final isAthlete = auth?.isAthlete ?? false;

    if (!isCoach && !isAthlete) {
      return const Scaffold(
        body: Center(child: Text('No role assigned')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team'),
        centerTitle: true,
        bottom: (isCoach && isAthlete)
            ? TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(icon: Icon(Icons.sports), text: 'My Athletes'),
                  Tab(icon: Icon(Icons.directions_run), text: 'My Coaches'),
                ],
              )
            : null,
      ),
      body: Consumer<CoachAthleteProvider>(
        builder: (_, prov, __) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isCoach && isAthlete) {
            return TabBarView(
              controller: _tabCtrl,
              children: [
                _UserList(
                  users: prov.athletes,
                  emptyText: 'No athletes yet',
                  emptyIcon: Icons.person_add_outlined,
                  onMessage: (u) => _openChat(u),
                ),
                _UserList(
                  users: prov.coaches,
                  emptyText: 'No coaches yet',
                  emptyIcon: Icons.sports_outlined,
                  onMessage: (u) => _openChat(u),
                ),
              ],
            );
          }

          if (isCoach) {
            return _UserList(
              users: prov.athletes,
              emptyText: 'No athletes yet',
              emptyIcon: Icons.person_add_outlined,
              onMessage: (u) => _openChat(u),
            );
          }

          return _UserList(
            users: prov.coaches,
            emptyText: 'No coaches yet',
            emptyIcon: Icons.sports_outlined,
            onMessage: (u) => _openChat(u),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isCoach && isAthlete) {
            _showAddDialog(_tabCtrl.index == 0);
          } else {
            _showAddDialog(isCoach);
          }
        },
        icon: const Icon(Icons.person_add),
        label: Text(isCoach && (_tabCtrl.index == 0 || !isAthlete)
            ? 'Add Athlete'
            : 'Request Coach'),
      ),
    );
  }

  void _openChat(CoachAthleteUser user) {
    context.read<MessageProvider>().clearMessages();
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'userId': user.id, 'name': user.fullName},
    );
  }
}

class _UserList extends StatelessWidget {
  final List<CoachAthleteUser> users;
  final String emptyText;
  final IconData emptyIcon;
  final void Function(CoachAthleteUser) onMessage;

  const _UserList({
    required this.users,
    required this.emptyText,
    required this.emptyIcon,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(emptyText, style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) {
        final u = users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cs.primaryContainer,
              child: Text(
                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                style: TextStyle(color: cs.onPrimaryContainer),
              ),
            ),
            title: Text(u.fullName.isNotEmpty ? u.fullName : u.email),
            subtitle: Text(u.email),
            trailing: IconButton(
              icon: const Icon(Icons.chat_outlined),
              onPressed: () => onMessage(u),
            ),
          ),
        );
      },
    );
  }
}
