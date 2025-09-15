import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskHistoryScreen extends StatelessWidget {
  final Task task;

  const TaskHistoryScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final sortedHistory = List<TaskHistory>.from(task.history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first

    return Scaffold(
      appBar: AppBar(
        title: Text('${task.name} - History'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: task.history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Noch keine Ausführungen',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Die History wird hier angezeigt'),
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
                          'Zusammenfassung',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Gesamte Ausführungen:'),
                            Text(
                              '${task.history.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Erste Ausführung:'),
                            Text(
                              task.history.isNotEmpty
                                  ? DateFormat('dd.MM.yyyy').format(
                                      task.history
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
                            Text('Letzte Ausführung:'),
                            Text(
                              task.history.isNotEmpty
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
                                    ? 'Heute, ${DateFormat('HH:mm').format(historyItem.timestamp)}'
                                    : isYesterday
                                        ? 'Gestern, ${DateFormat('HH:mm').format(historyItem.timestamp)}'
                                        : DateFormat('dd.MM.yyyy HH:mm').format(historyItem.timestamp),
                              ),
                              if (historyItem.participants.length > 1)
                                Text(
                                  'Aus ${historyItem.participants.length} Teilnehmern',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          trailing: Text(
                            '#${task.history.length - index}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
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
    if (task.history.isEmpty) return [];

    // Count occurrences of each participant
    final participantCounts = <String, int>{};
    for (final history in task.history) {
      participantCounts[history.selectedPerson] =
          (participantCounts[history.selectedPerson] ?? 0) + 1;
    }

    // Sort by count (descending)
    final sortedParticipants = participantCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      const Divider(),
      Text(
        'Häufigkeit der Teilnehmer:',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
      ...sortedParticipants.map((entry) {
        final percentage = (entry.value / task.history.length * 100).round();
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
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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