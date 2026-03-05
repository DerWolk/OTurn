import 'package:flutter/material.dart';
import 'models/group.dart';
import 'screens/create_group_screen.dart';

void main() {
  runApp(const OTurnApp());
}

class OTurnApp extends StatelessWidget {
  const OTurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTurn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Group> _groups = [];

  void _addGroup(Group group) {
    setState(() {
      _groups.add(group);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TasksScreen(),
      GroupsScreen(
        groups: _groups,
        onGroupCreated: _addGroup,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTurn'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task),
            label: 'Aufgaben',
          ),
          NavigationDestination(
            icon: Icon(Icons.group),
            label: 'Gruppen',
          ),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Keine Aufgaben vorhanden',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Erstelle deine erste Aufgabe'),
          const SizedBox(height: 24),
          FloatingActionButton.extended(
            onPressed: () {
              // TODO: Navigate to create task screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Aufgabe erstellen'),
          ),
        ],
      ),
    );
  }
}

class GroupsScreen extends StatelessWidget {
  final List<Group> groups;
  final Function(Group) onGroupCreated;

  const GroupsScreen({
    super.key,
    required this.groups,
    required this.onGroupCreated,
  });

  Future<void> _navigateToCreateGroup(BuildContext context) async {
    final result = await Navigator.of(context).push<Group>(
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );

    if (result != null) {
      onGroupCreated(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Keine Gruppen vorhanden',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('Erstelle deine erste Gruppe'),
            const SizedBox(height: 24),
            FloatingActionButton.extended(
              onPressed: () => _navigateToCreateGroup(context),
              icon: const Icon(Icons.add),
              label: const Text('Gruppe erstellen'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(group.name[0].toUpperCase()),
              ),
              title: Text(group.name),
              subtitle: Text('${group.members.length} Mitglieder'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to group details
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateGroup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
