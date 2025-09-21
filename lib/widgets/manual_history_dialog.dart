import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class ManualHistoryDialog extends StatefulWidget {
  final List<String> availableMembers;
  final TaskHistory? editingHistory;
  final Function(TaskHistory) onSave;

  const ManualHistoryDialog({
    super.key,
    required this.availableMembers,
    this.editingHistory,
    required this.onSave,
  });

  @override
  State<ManualHistoryDialog> createState() => _ManualHistoryDialogState();
}

class _ManualHistoryDialogState extends State<ManualHistoryDialog> {
  late String? selectedPerson;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.editingHistory != null) {
      selectedPerson = widget.editingHistory!.selectedPerson;
      selectedDate = DateTime(
        widget.editingHistory!.timestamp.year,
        widget.editingHistory!.timestamp.month,
        widget.editingHistory!.timestamp.day,
      );
      selectedTime = TimeOfDay.fromDateTime(widget.editingHistory!.timestamp);
    } else {
      selectedPerson = widget.availableMembers.isNotEmpty ? widget.availableMembers.first : null;
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingHistory != null;

    return AlertDialog(
      title: Text(isEditing ? 'History bearbeiten' : 'Manueller History-Eintrag'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ausgewählte Person:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedPerson,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: widget.availableMembers.map((member) {
                return DropdownMenuItem(
                  value: member,
                  child: Text(member),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPerson = value;
                });
              },
            ),

            const SizedBox(height: 16),

            Text(
              'Datum und Zeit:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(selectedTime.format(context)),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _canSave() ? _save : null,
          child: Text(isEditing ? 'Speichern' : 'Hinzufügen'),
        ),
      ],
    );
  }

  bool _canSave() {
    return selectedPerson != null;
  }

  void _save() {
    if (!_canSave()) return;

    final timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final history = TaskHistory(
      selectedPerson: selectedPerson!,
      timestamp: timestamp,
      participants: widget.availableMembers,
    );

    widget.onSave(history);
    Navigator.of(context).pop();
  }
}