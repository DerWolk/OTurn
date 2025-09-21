import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/image_picker_widget.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task; // null for creating, Task for editing
  final VoidCallback? onDataChanged;

  const CreateTaskScreen({super.key, this.task, this.onDataChanged});

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
  String? _selectedImagePath;

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
      _selectedImagePath = widget.task!.imagePath;

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

      // Update fair queue to match current participants when editing
      List<String> updatedFairQueue = List.from(widget.task?.fairQueue ?? []);
      if (_isEditing) {
        // Remove excluded members from fair queue
        updatedFairQueue.removeWhere((member) => _excludedMembers.contains(member));

        // Add new participants to fair queue if they're not already there
        for (final participant in _currentParticipants) {
          if (!updatedFairQueue.contains(participant)) {
            updatedFairQueue.add(participant);
          }
        }

        // Remove participants that are no longer in current participants
        updatedFairQueue.removeWhere((member) => !_currentParticipants.contains(member));
      }

      final task = _isEditing
          ? (_selectedImagePath == null
              ? widget.task!.copyWith(
                  name: _nameController.text.trim(),
                  groupId: _selectedGroup!.id,
                  fairMode: _fairMode,
                  additionalMembers: List.from(_additionalMembers),
                  excludedMembers: List.from(_excludedMembers),
                  fairQueue: updatedFairQueue,
                  clearImagePath: true,
                  lastUpdated: DateTime.now(),
                )
              : widget.task!.copyWith(
                  name: _nameController.text.trim(),
                  groupId: _selectedGroup!.id,
                  fairMode: _fairMode,
                  additionalMembers: List.from(_additionalMembers),
                  excludedMembers: List.from(_excludedMembers),
                  fairQueue: updatedFairQueue,
                  imagePath: _selectedImagePath,
                  lastUpdated: DateTime.now(),
                ))
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
              imagePath: _selectedImagePath,
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

                  // Task Image
                  Center(
                    child: ImagePickerWidget(
                      imagePath: _selectedImagePath,
                      onImageSelected: (imagePath) async {
                        setState(() {
                          _selectedImagePath = imagePath;
                        });

                        // Auto-save if editing existing task
                        if (widget.task != null) {
                          final updatedTask = imagePath == null
                              ? widget.task!.copyWith(clearImagePath: true)
                              : widget.task!.copyWith(imagePath: imagePath);
                          await StorageService.saveTask(updatedTask);
                          // Notify parent to refresh data
                          widget.onDataChanged?.call();
                        }
                      },
                      size: 120,
                      placeholder: 'Aufgabenbild',
                      placeholderIcon: Icons.task_alt,
                    ),
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
                        child: Text('${group.name} (${group.members.length} Mitglieder)'),
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