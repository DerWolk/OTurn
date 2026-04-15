import 'package:flutter/material.dart';
import 'dart:math';
import '../models/task.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import 'task_history_screen.dart';

class TaskExecutionScreen extends StatefulWidget {
  final Task task;
  final Group group;

  const TaskExecutionScreen({
    super.key,
    required this.task,
    required this.group,
  });

  @override
  State<TaskExecutionScreen> createState() => _TaskExecutionScreenState();
}

class _TaskExecutionScreenState extends State<TaskExecutionScreen>
    with TickerProviderStateMixin {
  late AnimationController _diceController;
  late AnimationController _resultController;
  late Animation<double> _diceAnimation;
  late Animation<double> _resultAnimation;

  String? _selectedPerson;
  bool _isRolling = false;
  List<String> _currentParticipants = [];
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _loadCurrentTask();
    _calculateParticipants();

    _diceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _diceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _diceController, curve: Curves.easeInOut),
    );

    _resultAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _diceController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _loadCurrentTask() {
    // Always load the latest version from storage
    final latestTask = StorageService.getTask(widget.task.id);
    _currentTask = latestTask ?? widget.task;
  }

  void _calculateParticipants() {
    final participants = <String>[];

    // Add group members
    participants.addAll(widget.group.members);

    // Add additional members
    participants.addAll(_currentTask.additionalMembers);

    // Remove excluded members
    participants.removeWhere((member) => _currentTask.excludedMembers.contains(member));

    _currentParticipants = participants;
  }

  String _selectNextPerson() {
    if (_currentParticipants.isEmpty) {
      throw Exception('No participants available');
    }

    if (_currentTask.fairMode) {
      // Fair mode: use fair queue
      if (_currentTask.fairQueue.isEmpty) {
        // Refill queue with all participants
        final newQueue = List<String>.from(_currentParticipants);
        newQueue.shuffle();
        return newQueue.first;
      } else {
        // Take next person from queue
        return _currentTask.fairQueue.first;
      }
    } else {
      // Random mode: completely random selection
      final random = Random();
      return _currentParticipants[random.nextInt(_currentParticipants.length)];
    }
  }

  Future<void> _rollDice() async {
    if (_isRolling || _currentParticipants.isEmpty) return;

    setState(() {
      _isRolling = true;
      _selectedPerson = null;
    });

    // Start dice animation
    await _diceController.forward();

    // Select person
    final selectedPerson = _selectNextPerson();

    // Update task with selection
    await _updateTaskWithSelection(selectedPerson);

    setState(() {
      _selectedPerson = selectedPerson;
      _isRolling = false;
    });

    // Reset dice animation
    _diceController.reset();

    // Start result animation
    await _resultController.forward();
  }

  Future<void> _updateTaskWithSelection(String selectedPerson) async {
    final now = DateTime.now();

    // Create history entry
    final historyEntry = TaskHistory(
      selectedPerson: selectedPerson,
      participants: List.from(_currentParticipants),
      timestamp: now,
    );

    // Update fair queue if in fair mode
    List<String> newFairQueue = List.from(_currentTask.fairQueue);
    if (_currentTask.fairMode) {
      if (newFairQueue.isEmpty) {
        // Refill queue and remove selected person
        newFairQueue = List<String>.from(_currentParticipants);
        newFairQueue.shuffle();
        newFairQueue.remove(selectedPerson);
      } else {
        // Remove selected person from front of queue
        newFairQueue.removeAt(0);
      }
    }

    // Update task
    final updatedTask = _currentTask.copyWith(
      history: [..._currentTask.history, historyEntry],
      fairQueue: newFairQueue,
      lastUpdated: now,
    );

    // Update local state
    setState(() {
      _currentTask = updatedTask;
    });

    await StorageService.saveTask(updatedTask);
  }

  void _resetResult() {
    setState(() {
      _selectedPerson = null;
    });
    _resultController.reset();
  }

  void _showTaskOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Aufgaben-Optionen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(_currentTask.fairMode ? Icons.shuffle : Icons.balance),
              title: Text(_currentTask.fairMode ? 'Zu Zufalls-Modus wechseln' : 'Zu Fair-Modus wechseln'),
              subtitle: Text(_currentTask.fairMode
                ? 'Komplett zufällige Auswahl bei jedem Würfeln'
                : 'Faire Rotation - jeder kommt einmal dran'),
              onTap: () {
                Navigator.pop(context);
                _toggleFairMode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('History anzeigen'),
              subtitle: Text('${_currentTask.history.length} Ausführungen anzeigen'),
              onTap: () {
                Navigator.pop(context);
                _showHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.orange),
              title: const Text('History löschen'),
              subtitle: const Text('Alle bisherigen Ausführungen löschen'),
              onTap: () {
                Navigator.pop(context);
                _clearHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Fair-Queue zurücksetzen'),
              subtitle: const Text('Warteschlange neu mischen'),
              enabled: _currentTask.fairMode,
              onTap: _currentTask.fairMode ? () {
                Navigator.pop(context);
                _resetFairQueue();
              } : null,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleFairMode() async {
    final updatedTask = _currentTask.copyWith(
      fairMode: !_currentTask.fairMode,
      fairQueue: [], // Reset queue when switching modes
      lastUpdated: DateTime.now(),
    );

    setState(() {
      _currentTask = updatedTask;
    });

    await StorageService.saveTask(updatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_currentTask.fairMode
          ? 'Fair-Modus aktiviert'
          : 'Zufalls-Modus aktiviert'),
      ),
    );
  }

  void _clearHistory() async {
    final updatedTask = _currentTask.copyWith(
      history: [],
      lastUpdated: DateTime.now(),
    );

    setState(() {
      _currentTask = updatedTask;
    });

    await StorageService.saveTask(updatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History gelöscht')),
    );
  }

  void _resetFairQueue() async {
    final updatedTask = _currentTask.copyWith(
      fairQueue: [],
      lastUpdated: DateTime.now(),
    );

    setState(() {
      _currentTask = updatedTask;
    });

    await StorageService.saveTask(updatedTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fair-Queue zurückgesetzt')),
    );
  }

  void _showHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskHistoryScreen(task: _currentTask),
      ),
    );
  }

  void _showDetailedHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ausführungs-Details (${_currentTask.history.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _currentTask.history.isEmpty
              ? const Center(child: Text('Noch keine Ausführungen'))
              : ListView.builder(
                  itemCount: _currentTask.history.length,
                  itemBuilder: (context, index) {
                    final entry = _currentTask.history.reversed.toList()[index];
                    final date = entry.timestamp;
                    final isToday = DateTime.now().difference(date).inDays == 0;
                    final isYesterday = DateTime.now().difference(date).inDays == 1;

                    String dateStr;
                    if (isToday) {
                      dateStr = 'Heute ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    } else if (isYesterday) {
                      dateStr = 'Gestern ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    } else {
                      dateStr = '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text(entry.selectedPerson[0].toUpperCase()),
                      ),
                      title: Text(entry.selectedPerson),
                      subtitle: Text(dateStr),
                      trailing: Text('${entry.participants.length} Teilnehmer'),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _showFairQueue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warteschlange (${_currentTask.fairQueue.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: _currentTask.fairQueue.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text('Warteschlange ist leer'),
                      const SizedBox(height: 8),
                      const Text(
                        'Alle waren schon dran - nächstes Würfeln startet neue Runde',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Noch nicht dran:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _currentTask.fairQueue.length,
                        itemBuilder: (context, index) {
                          final person = _currentTask.fairQueue[index];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.orange,
                              child: Text(person[0].toUpperCase()),
                            ),
                            title: Text(person),
                            trailing: Text('Position ${index + 1}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showTaskOptions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Task Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _currentTask.fairMode ? Icons.balance : Icons.shuffle,
                          color: _currentTask.fairMode ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentTask.fairMode ? 'Fair-Modus' : 'Zufalls-Modus',
                          style: TextStyle(
                            color: _currentTask.fairMode ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_currentTask.fairMode)
                          Row(
                            children: [
                              Text(
                                'Warteschlange: ${_currentTask.fairQueue.length}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _showFairQueue,
                                child: Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gruppe: ${widget.group.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${_currentParticipants.length} Teilnehmer',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (_currentTask.history.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Letzte Ausführungen: ${_currentTask.history.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _showDetailedHistory,
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (_currentTask.history.isNotEmpty)
                        Text(
                          'Zuletzt: ${_currentTask.history.last.selectedPerson}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Dice Animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedPerson == null) ...[
                      // Dice Icon
                      AnimatedBuilder(
                        animation: _diceAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _diceAnimation.value * 4 * 3.14159,
                            child: Icon(
                              Icons.casino,
                              size: 120,
                              color: _isRolling
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _isRolling ? 'Würfeln...' : 'Tippe zum Würfeln',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _isRolling
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        ),
                      ),
                    ] else ...[
                      // Result
                      AnimatedBuilder(
                        animation: _resultAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _resultAnimation.value,
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    _selectedPerson![0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedPerson!,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ist dran!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            if (_selectedPerson == null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _currentParticipants.isEmpty || _isRolling ? null : _rollDice,
                  icon: Icon(_isRolling ? Icons.hourglass_empty : Icons.casino),
                  label: Text(_isRolling ? 'Würfeln...' : 'Würfeln'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetResult,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Nochmal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.done),
                      label: const Text('Fertig'),
                    ),
                  ),
                ],
              ),
            ],

            if (_currentParticipants.isEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Keine Teilnehmer verfügbar',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}