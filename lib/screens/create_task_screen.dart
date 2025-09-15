import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task; // null for creating, Task for editing

  const CreateTaskScreen({super.key, this.task});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<Group> _availableGroups = [];
  Group? _selectedGroup;
  bool _fairMode = true;
  List<String> _additionalMembers = [];
  List<String> _excludedMembers = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();

    if (widget.task != null) {
      // Pre-fill form for editing
      _nameController.text = widget.task!.name;
      _fairMode = widget.task!.fairMode;
      _additionalMembers = List.from(widget.task!.additionalMembers);
      _excludedMembers = List.from(widget.task!.excludedMembers);

      // Find and set selected group
      if (widget.task!.groupId != null) {
        _selectedGroup = _availableGroups.firstWhere(
          (group) => group.id == widget.task!.groupId,
          orElse: () => _availableGroups.first,
        );
      }
    }
  }

  void _loadGroups() {
    setState(() {
      _availableGroups = StorageService.getAllGroups();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.task != null;

  List<String> get _currentParticipants {
    final participants = <String>[];

    // Add group members
    if (_selectedGroup != null) {
      participants.addAll(_selectedGroup!.members);
    }

    // Add additional members
    participants.addAll(_additionalMembers);

    // Remove excluded members
    participants.removeWhere((member) => _excludedMembers.contains(member));

    return participants;
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte wähle eine Gruppe aus')),
        );
        return;
      }

      if (_currentParticipants.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Die Aufgabe muss mindestens einen Teilnehmer haben')),
        );
        return;
      }

      final task = _isEditing
          ? widget.task!.copyWith(
              name: _nameController.text.trim(),
              groupId: _selectedGroup!.id,
              fairMode: _fairMode,
              additionalMembers: List.from(_additionalMembers),
              excludedMembers: List.from(_excludedMembers),
              lastUpdated: DateTime.now(),
            )
          : Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text.trim(),
              groupId: _selectedGroup!.id,
              fairMode: _fairMode,
              additionalMembers: List.from(_additionalMembers),
              excludedMembers: List.from(_excludedMembers),
              history: [],
              fairQueue: List.from(_currentParticipants),
              createdAt: DateTime.now(),
              lastUpdated: DateTime.now(),
            );

      Navigator.of(context).pop(task);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Aufgabe bearbeiten' : 'Aufgabe erstellen'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: _availableGroups.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keine Gruppen vorhanden',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Erstelle zuerst eine Gruppe im Gruppen-Tab'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Task Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Aufgabenname',
                      hintText: 'z.B. Mail an GL verfassen',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte gib einen Aufgabennamen ein';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Group Selection
                  Text(
                    'Gruppe auswählen',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Group>(
                    value: _selectedGroup,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Gruppe wählen',
                    ),
                    items: _availableGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text(group.name[0].toUpperCase()),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(group.name),
                                  Text(
                                    '${group.members.length} Mitglieder',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (group) {
                      setState(() {
                        _selectedGroup = group;
                        // Reset excluded members when group changes
                        _excludedMembers.clear();
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Fair Mode Toggle
                  Card(
                    child: SwitchListTile(
                      title: const Text('Fair-Switch'),
                      subtitle: Text(_fairMode
                          ? 'Faire Rotation - jeder kommt einmal dran'
                          : 'Zufällige Auswahl bei jedem Würfeln'),
                      value: _fairMode,
                      onChanged: (value) {
                        setState(() {
                          _fairMode = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Current Participants Preview
                  if (_selectedGroup != null) ...[
                    Text(
                      'Teilnehmer (${_currentParticipants.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _currentParticipants.isEmpty
                            ? const Text(
                                'Keine Teilnehmer - alle sind ausgeschlossen',
                                style: TextStyle(color: Colors.orange),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _currentParticipants.map((member) {
                                  return Chip(
                                    avatar: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        member[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    label: Text(member),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Exclude Members
                    if (_selectedGroup!.members.isNotEmpty)
                      ExpansionTile(
                        title: const Text('Mitglieder ausschließen'),
                        subtitle: Text('${_excludedMembers.length} ausgeschlossen'),
                        children: _selectedGroup!.members.map((member) {
                          final isExcluded = _excludedMembers.contains(member);
                          return CheckboxListTile(
                            title: Text(member),
                            subtitle: Text(isExcluded ? 'Ausgeschlossen' : 'Teilnehmer'),
                            value: isExcluded,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _excludedMembers.add(member);
                                } else {
                                  _excludedMembers.remove(member);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}