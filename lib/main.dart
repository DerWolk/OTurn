import 'package:flutter/material.dart';
import 'models/group.dart';
import 'screens/create_group_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
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

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _groups = StorageService.getAllGroups();
    });
  }

  void _addGroup(Group group) async {
    await StorageService.saveGroup(group);
    _loadGroups();
  }

  void _deleteGroup(String groupId) async {
    await StorageService.deleteGroup(groupId);
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TasksScreen(),
      GroupsScreen(
        groups: _groups,
        onGroupCreated: _addGroup,
        onGroupDeleted: _deleteGroup,
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
  final Function(String) onGroupDeleted;

  const GroupsScreen({
    super.key,
    required this.groups,
    required this.onGroupCreated,
    required this.onGroupDeleted,
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

  Future<void> _navigateToEditGroup(BuildContext context, Group group) async {
    final result = await Navigator.of(context).push<Group>(
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(group: group),
      ),
    );

    if (result != null) {
      onGroupCreated(result);
    }
  }

  void _showDeleteDialog(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Gruppe "${group.name}" löschen?'),
        content: const Text('Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGroupDeleted(group.id);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditGroup(context, group);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, group);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Bearbeiten'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Löschen'),
                    ),
                  ),
                ],
              ),
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
