import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/group.dart';
import 'models/task.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/task_execution_screen.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  final themeService = ThemeService();
  await themeService.init();
  runApp(OTurnApp(themeService: themeService));
}

class OTurnApp extends StatelessWidget {
  final ThemeService themeService;

  const OTurnApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'OTurn',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Über OTurn'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'OTurn hilft bei der fairen Verteilung von Aufgaben in Teams.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('🎯 Aufgaben', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Erstelle wiederkehrende Aufgaben für deine Gruppen\n• Wähle zwischen Zufalls- und Fair-Modus\n• Verfolge die Historie aller Ausführungen'),
              SizedBox(height: 12),
              Text('👥 Gruppen', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Verwalte Teams und deren Mitglieder\n• Autocomplete basierend auf bestehenden Namen\n• Einfache Bearbeitung und Verwaltung'),
              SizedBox(height: 12),
              Text('⚖️ Fair-Modus', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Jeder kommt einmal dran, bevor die nächste Runde startet\n• Perfekt für regelmäßige Aufgaben wie Müll rausbringen'),
              SizedBox(height: 12),
              Text('🎲 Zufalls-Modus', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Komplett zufällige Auswahl bei jedem Würfeln\n• Ideal für spontane Entscheidungen'),
              SizedBox(height: 12),
              Text('💾 Lokale Speicherung', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Alle Daten werden nur auf diesem Gerät gespeichert\n• Keine Server, keine Internetverbindung nötig'),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),
              Text('📱 Über diese App', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Entwickelt von Waldemar Stockmann'),
              Text('© 2025 Alle Rechte vorbehalten', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
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
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
                tooltip: themeService.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Hilfe',
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.task_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Keine Aufgaben vorhanden',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Erstelle deine erste Aufgabe für ein Team\nund lass das faire Würfeln beginnen!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateTask(context),
                icon: const Icon(Icons.add),
                label: const Text('Erste Aufgabe erstellen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            if (index >= tasks.length) return const SizedBox.shrink();
            final task = tasks[index];
            if (task == null) return const SizedBox.shrink();
            final groupName = _getGroupName(task.groupId);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: task.fairMode
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          task.fairMode ? Icons.balance : Icons.shuffle,
                          color: task.fairMode ? Colors.green : Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              groupName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: task.fairMode ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task.fairMode ? 'Fair-Modus' : 'Zufalls-Modus',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
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
                    ],
                  ),
                ),
              ),
            );
        },
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.groups,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Keine Gruppen vorhanden',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Erstelle deine erste Gruppe mit Teammitgliedern\num Aufgaben fair zu verteilen',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateGroup(context),
                icon: const Icon(Icons.add),
                label: const Text('Erste Gruppe erstellen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
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
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // TODO: Navigate to group details
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        group.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${group.members.length} Mitglieder',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
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
                  ],
                ),
              ),
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
