import 'package:flutter/material.dart';
import 'models/group.dart';
import 'models/task.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/task_execution_screen.dart';
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
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _groups = StorageService.getAllGroups();
      _tasks = StorageService.getAllTasks();
    });
  }

  void _addGroup(Group group) async {
    await StorageService.saveGroup(group);
    _loadData();
  }

  void _deleteGroup(String groupId) async {
    await StorageService.deleteGroup(groupId);
    _loadData();
  }

  void _addTask(Task task) async {
    await StorageService.saveTask(task);
    _loadData();
  }

  void _deleteTask(String taskId) async {
    await StorageService.deleteTask(taskId);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TasksScreen(
        tasks: _tasks,
        groups: _groups,
        onTaskCreated: _addTask,
        onTaskDeleted: _deleteTask,
      ),
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
  final List<Task> tasks;
  final List<Group> groups;
  final Function(Task) onTaskCreated;
  final Function(String) onTaskDeleted;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.groups,
    required this.onTaskCreated,
    required this.onTaskDeleted,
  });

  Future<void> _navigateToCreateTask(BuildContext context) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) => const CreateTaskScreen(),
      ),
    );

    if (result != null) {
      onTaskCreated(result);
    }
  }

  Future<void> _navigateToEditTask(BuildContext context, Task task) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(task: task),
      ),
    );

    if (result != null) {
      onTaskCreated(result);
    }
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aufgabe "${task.name}" löschen?'),
        content: const Text('Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onTaskDeleted(task.id);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  String _getGroupName(String? groupId) {
    if (groupId == null) return 'Unbekannte Gruppe';
    final group = groups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => Group(
        id: '',
        name: 'Unbekannte Gruppe',
        members: [],
        createdAt: DateTime.now(),
      ),
    );
    return group.name;
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
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
              onPressed: () => _navigateToCreateTask(context),
              icon: const Icon(Icons.add),
              label: const Text('Aufgabe erstellen'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final groupName = _getGroupName(task.groupId);

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: task.fairMode ? Colors.green : Colors.blue,
                child: Icon(
                  task.fairMode ? Icons.balance : Icons.shuffle,
                  color: Colors.white,
                ),
              ),
              title: Text(task.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(groupName),
                  Text(
                    task.fairMode ? 'Fair-Modus' : 'Zufalls-Modus',
                    style: TextStyle(
                      color: task.fairMode ? Colors.green : Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditTask(context, task);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, task);
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
                final group = groups.firstWhere(
                  (g) => g.id == task.groupId,
                  orElse: () => Group(
                    id: '',
                    name: 'Unbekannte Gruppe',
                    members: [],
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskExecutionScreen(
                      task: task,
                      group: group,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateTask(context),
        child: const Icon(Icons.add),
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
