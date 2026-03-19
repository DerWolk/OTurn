import 'package:flutter/material.dart';
import 'dart:math';
import '../models/task.dart';
import '../models/group.dart';
import '../services/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
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

  void _calculateParticipants() {
    final participants = <String>[];

    // Add group members
    participants.addAll(widget.group.members);

    // Add additional members
    participants.addAll(widget.task.additionalMembers);

    // Remove excluded members
    participants.removeWhere((member) => widget.task.excludedMembers.contains(member));

    _currentParticipants = participants;
  }

  String _selectNextPerson() {
    if (_currentParticipants.isEmpty) {
      throw Exception('No participants available');
    }

    if (widget.task.fairMode) {
      // Fair mode: use fair queue
      if (widget.task.fairQueue.isEmpty) {
        // Refill queue with all participants
        final newQueue = List<String>.from(_currentParticipants);
        newQueue.shuffle();
        final updatedTask = widget.task.copyWith(fairQueue: newQueue);
        StorageService.saveTask(updatedTask);
        return newQueue.first;
      } else {
        // Take next person from queue
        return widget.task.fairQueue.first;
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
    List<String> newFairQueue = List.from(widget.task.fairQueue);
    if (widget.task.fairMode && newFairQueue.isNotEmpty) {
      newFairQueue.removeAt(0); // Remove selected person from front of queue
    }

    // Update task
    final updatedTask = widget.task.copyWith(
      history: [...widget.task.history, historyEntry],
      fairQueue: newFairQueue,
      lastUpdated: now,
    );

    await StorageService.saveTask(updatedTask);
  }

  void _resetResult() {
    setState(() {
      _selectedPerson = null;
    });
    _resultController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                          widget.task.fairMode ? Icons.balance : Icons.shuffle,
                          color: widget.task.fairMode ? Colors.green : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.task.fairMode ? 'Fair-Modus' : 'Zufalls-Modus',
                          style: TextStyle(
                            color: widget.task.fairMode ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
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