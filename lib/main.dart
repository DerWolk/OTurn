import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'models/group.dart';
import 'models/task.dart';
import 'screens/create_group_screen.dart';
import 'screens/create_task_screen.dart';
import 'screens/task_execution_screen.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'services/language_service.dart';
import 'services/image_service.dart';
import 'screens/settings_screen.dart';
import 'widgets/universal_image.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await ImageService.migrateImages();
  await StorageService.cleanupInvalidImages();
  final themeService = ThemeService();
  await themeService.init();
  final languageService = LanguageService();
  await languageService.init();
  runApp(OTurnApp(themeService: themeService, languageService: languageService));
}

class OTurnApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const OTurnApp({super.key, required this.themeService, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: Consumer2<ThemeService, LanguageService>(
        builder: (context, themeService, languageService, child) {
          return MaterialApp(
            title: 'OTurn',
            theme: ThemeService.lightTheme,
            darkTheme: ThemeService.darkTheme,
            themeMode: themeService.themeMode,
            locale: languageService.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
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
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;
  bool _potatoModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (kDebugMode) {
      print('HomeScreen: _loadData called - refreshing groups and tasks');
    }
    setState(() {
      _groups = StorageService.getAllGroups();
      _tasks = StorageService.getAllTasks();
    });
    if (kDebugMode) {
      print('HomeScreen: Loaded ${_groups.length} groups and ${_tasks.length} tasks');
      for (var group in _groups) {
        print('Group: ${group.name}, imagePath: ${group.imagePath}');
      }
    }
  }

  void _addGroup(Group group) async {
    await StorageService.saveGroup(group);
    _loadData();
  }

  void _deleteGroup(String groupId) async {
    await StorageService.deleteGroup(groupId);
    _loadData();
  }

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastLogoTap != null && now.difference(_lastLogoTap!).inSeconds > 3) {
      _logoTapCount = 0;
    }

    _logoTapCount++;
    _lastLogoTap = now;

    if (_logoTapCount >= 5) {
      _logoTapCount = 0;
      setState(() {
        _potatoModeEnabled = !_potatoModeEnabled;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 8),
              Text(_potatoModeEnabled
                ? AppLocalizations.of(context)!.potatoModeEnabled
                : AppLocalizations.of(context)!.potatoModeDisabled),
            ],
          ),
          backgroundColor: Colors.deepPurple,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
        title: Text(AppLocalizations.of(context)!.about),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.aboutDescription,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.aboutTasksTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context)!.aboutTasksDescription),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.aboutGroupsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context)!.aboutGroupsManagementDescription),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.aboutFairModeTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context)!.aboutFairModeDescription),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.aboutRandomModeTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context)!.aboutRandomModeDescription),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.aboutDataStorageTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(kIsWeb
                ? AppLocalizations.of(context)!.aboutDataStorageDescriptionWeb
                : AppLocalizations.of(context)!.aboutDataStorageDescriptionMobile),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.aboutThisAppTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppLocalizations.of(context)!.developedBy),
              Text(AppLocalizations.of(context)!.allRightsReservedShort, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.understood),
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
        onDataChanged: _loadData,
        potatoModeEnabled: _potatoModeEnabled,
      ),
      GroupsScreen(
        groups: _groups,
        onGroupCreated: _addGroup,
        onGroupDeleted: _deleteGroup,
        onDataChanged: _loadData,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _onLogoTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'OTurn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeService.toggleTheme(),
                tooltip: themeService.isDarkMode ? AppLocalizations.of(context)!.lightMode : AppLocalizations.of(context)!.darkMode,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: AppLocalizations.of(context)!.help,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index.clamp(0, 1)),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.task),
            label: AppLocalizations.of(context)!.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.group),
            label: AppLocalizations.of(context)!.groups,
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
  final VoidCallback? onDataChanged;
  final bool potatoModeEnabled;

  const TasksScreen({
    super.key,
    required this.tasks,
    required this.groups,
    required this.onTaskCreated,
    required this.onTaskDeleted,
    this.onDataChanged,
    this.potatoModeEnabled = false,
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
        builder: (context) => CreateTaskScreen(
          task: task,
          onDataChanged: onDataChanged,
        ),
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
        title: Text(AppLocalizations.of(context)!.deleteTaskTitle(task.name)),
        content: Text(AppLocalizations.of(context)!.deleteTaskContent),
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
            child: Text(AppLocalizations.of(context)!.delete),
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
                AppLocalizations.of(context)!.noTasksAvailable,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.noTasksSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateTask(context),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createFirstTask),
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
                        potatoModeEnabled: potatoModeEnabled,
                      ),
                    ),
                  ).then((_) {
                    // Reload data when returning from task execution
                    onDataChanged?.call();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (task.fairMode ? Colors.green : Colors.blue).withOpacity(0.1),
                              (task.fairMode ? Colors.green : Colors.blue).withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: task.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: UniversalImage(
                                  imagePath: task.imagePath,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      task.name[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: task.fairMode ? Colors.green : Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  task.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: task.fairMode ? Colors.green : Colors.blue,
                                  ),
                                ),
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
                                color: Theme.of(context).textTheme.bodyMedium?.color,
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
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: Text(AppLocalizations.of(context)!.edit),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete),
                              title: Text(AppLocalizations.of(context)!.delete),
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
  final VoidCallback? onDataChanged;

  const GroupsScreen({
    super.key,
    required this.groups,
    required this.onGroupCreated,
    required this.onGroupDeleted,
    this.onDataChanged,
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
        builder: (context) => CreateGroupScreen(
          group: group,
          onDataChanged: onDataChanged,
        ),
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
        title: Text(AppLocalizations.of(context)!.deleteGroupTitle(group.name)),
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
            child: Text(AppLocalizations.of(context)!.delete),
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
                AppLocalizations.of(context)!.noGroupsAvailable,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.noGroupsSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreateGroup(context),
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.createFirstGroup),
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
                      key: ValueKey('group_container_${group.id}_${group.imagePath ?? 'no_image'}'),
                      width: 64,
                      height: 64,
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
                      child: group.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: UniversalImage(
                                key: ValueKey('group_${group.id}_${group.imagePath}'),
                                imagePath: group.imagePath,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    group.name[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                group.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: const Icon(Icons.edit),
                            title: Text(AppLocalizations.of(context)!.edit),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: const Icon(Icons.delete),
                            title: Text(AppLocalizations.of(context)!.delete),
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
