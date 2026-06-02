import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/manual_history_dialog.dart';
import '../l10n/app_localizations.dart';

class TaskHistoryScreen extends StatefulWidget {
  final Task task;

  const TaskHistoryScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  late Task currentTask;

  @override
  void initState() {
    super.initState();
    currentTask = widget.task;
  }

  List<String> _getAvailableMembers() {
    final members = <String>{};

    if (currentTask.groupId != null) {
      final group = StorageService.getGroup(currentTask.groupId!);
      if (group != null) {
        members.addAll(group.members);
      }
    }

    members.addAll(currentTask.additionalMembers);
    members.removeWhere((member) => currentTask.excludedMembers.contains(member));

    return members.toList()..sort();
  }

  void _showManualHistoryDialog({TaskHistory? editingHistory, int? editingIndex}) {
    showDialog(
      context: context,
      builder: (context) => ManualHistoryDialog(
        availableMembers: _getAvailableMembers(),
        editingHistory: editingHistory,
        onSave: (history) => _saveHistory(history, editingIndex),
      ),
    );
  }

  void _saveHistory(TaskHistory history, int? editingIndex) async {
    final updatedHistory = List<TaskHistory>.from(currentTask.history);

    if (editingIndex != null) {
      updatedHistory[editingIndex] = history;
    } else {
      updatedHistory.add(history);
    }

    // Update fair queue if in fair mode
    List<String> newFairQueue = List<String>.from(currentTask.fairQueue);
    if (currentTask.fairMode && editingIndex == null) {
      // Only update queue for new entries, not edits
      newFairQueue.remove(history.selectedPerson);
    }

    final updatedTask = currentTask.copyWith(
      history: updatedHistory,
      fairQueue: newFairQueue,
      lastUpdated: DateTime.now(),
    );

    await StorageService.saveTask(updatedTask);

    setState(() {
      currentTask = updatedTask;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editingIndex != null ? AppLocalizations.of(context)!.historyUpdated : AppLocalizations.of(context)!.historyAdded),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteHistory(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteHistoryEntry),
        content: Text(AppLocalizations.of(context)!.deleteHistoryEntryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedHistory = List<TaskHistory>.from(currentTask.history)..removeAt(index);

      final updatedTask = currentTask.copyWith(
        history: updatedHistory,
        lastUpdated: DateTime.now(),
      );

      await StorageService.saveTask(updatedTask);

      setState(() {
        currentTask = updatedTask;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.historyEntryDeleted),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<TaskHistory>.from(currentTask.history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.historyTitle(currentTask.name)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showManualHistoryDialog(),
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.addHistoryManually,
          ),
        ],
      ),
      body: currentTask.history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Theme.of(context).iconTheme.color),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noExecutions,
                    style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.historyWillBeShown),
                ],
              ),
            )
          : Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.summary,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.totalExecutions),
                            Text(
                              '${currentTask.history.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.firstExecution),
                            Text(
                              currentTask.history.isNotEmpty
                                  ? DateFormat('dd.MM.yyyy').format(
                                      currentTask.history
                                          .map((h) => h.timestamp)
                                          .reduce((a, b) => a.isBefore(b) ? a : b),
                                    )
                                  : '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.of(context)!.lastExecution),
                            Text(
                              currentTask.history.isNotEmpty
                                  ? DateFormat('dd.MM.yyyy HH:mm').format(sortedHistory.first.timestamp)
                                  : '-',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Participant frequency
                        ..._buildParticipantStats(context),
                      ],
                    ),
                  ),
                ),

                // History List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem = sortedHistory[index];
                      final isToday = _isToday(historyItem.timestamp);
                      final isYesterday = _isYesterday(historyItem.timestamp);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              historyItem.selectedPerson[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            historyItem.selectedPerson,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isToday
                                    ? '${AppLocalizations.of(context)!.today}, ${DateFormat('HH:mm').format(historyItem.timestamp)}'
                                    : isYesterday
                                        ? '${AppLocalizations.of(context)!.yesterday}, ${DateFormat('HH:mm').format(historyItem.timestamp)}'
                                        : DateFormat('dd.MM.yyyy HH:mm').format(historyItem.timestamp),
                              ),
                              if (historyItem.participants.length > 1)
                                Text(
                                  AppLocalizations.of(context)!.fromParticipants(historyItem.participants.length),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#${currentTask.history.length - index}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    final originalIndex = currentTask.history.indexOf(historyItem);
                                    _showManualHistoryDialog(
                                      editingHistory: historyItem,
                                      editingIndex: originalIndex,
                                    );
                                  } else if (value == 'delete') {
                                    final originalIndex = currentTask.history.indexOf(historyItem);
                                    _deleteHistory(originalIndex);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, size: 16),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.edit),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete, size: 16),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!.delete),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildParticipantStats(BuildContext context) {
    if (currentTask.history.isEmpty) return [];

    // Count occurrences of each participant
    final participantCounts = <String, int>{};
    for (final history in currentTask.history) {
      participantCounts[history.selectedPerson] =
          (participantCounts[history.selectedPerson] ?? 0) + 1;
    }

    // Sort by count (descending)
    final sortedParticipants = participantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      const Divider(),
      Text(
        AppLocalizations.of(context)!.participantFrequency,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      for (final entry in sortedParticipants)
        Builder(
          builder: (context) {
            final percentage = (entry.value / currentTask.history.length * 100).round();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Row(
                    children: [
                      Text('${entry.value}x'),
                      const SizedBox(width: 8),
                      Text(
                        '($percentage%)',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
    ];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }
}