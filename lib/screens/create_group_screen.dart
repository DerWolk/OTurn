import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../widgets/image_picker_widget.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? group; // null for creating, Group for editing
  final VoidCallback? onDataChanged;

  const CreateGroupScreen({super.key, this.group, this.onDataChanged});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  final List<String> _members = [];
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      // Pre-fill form for editing
      _nameController.text = widget.group!.name;
      _members.addAll(widget.group!.members);
      _selectedImagePath = widget.group!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.group != null;

  void _addMember() {
    final name = _memberController.text.trim();
    if (name.isNotEmpty && !_members.contains(name)) {
      setState(() {
        _members.add(name);
        _memberController.clear();
      });
    }
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  void _saveGroup() {
    if (_formKey.currentState!.validate() && _members.isNotEmpty) {
      final group = _isEditing
          ? (_selectedImagePath == null
              ? widget.group!.copyWith(
                  name: _nameController.text.trim(),
                  members: List.from(_members),
                  clearImagePath: true,
                )
              : widget.group!.copyWith(
                  name: _nameController.text.trim(),
                  members: List.from(_members),
                  imagePath: _selectedImagePath,
                ))
          : Group(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text.trim(),
              members: List.from(_members),
              createdAt: DateTime.now(),
              imagePath: _selectedImagePath,
            );

      Navigator.of(context).pop(group);
    } else if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Füge mindestens ein Mitglied hinzu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Gruppe bearbeiten' : 'Gruppe erstellen'),
        actions: [
          TextButton(
            onPressed: _saveGroup,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Gruppenname',
                  hintText: 'z.B. Marketing Team',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte gib einen Gruppennamen ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ImagePickerWidget(
                imagePath: _selectedImagePath,
                onImageSelected: (imagePath) async {
                  if (kDebugMode) {
                    print('CreateGroupScreen: onImageSelected called with: $imagePath');
                  }
                  setState(() {
                    _selectedImagePath = imagePath;
                  });

                  // Auto-save if editing existing group
                  if (widget.group != null) {
                    if (kDebugMode) {
                      print('CreateGroupScreen: Auto-saving group with imagePath: $imagePath');
                    }
                    final updatedGroup = imagePath == null
                        ? widget.group!.copyWith(clearImagePath: true)
                        : widget.group!.copyWith(imagePath: imagePath);
                    await StorageService.saveGroup(updatedGroup);
                    if (kDebugMode) {
                      print('CreateGroupScreen: Group saved, calling onDataChanged');
                    }
                    // Notify parent to refresh data
                    widget.onDataChanged?.call();
                  }
                },
                size: 120,
                placeholder: 'Gruppenbild',
                placeholderIcon: Icons.group,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TypeAheadField<String>(
                      controller: _memberController,
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Mitglied hinzufügen',
                            hintText: 'Name eingeben',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addMember(),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        final allMembers = StorageService.getAllUniqueMembers();
                        return allMembers
                            .where((name) =>
                                name.toLowerCase().contains(pattern.toLowerCase()) &&
                                !_members.contains(name)) // Exclude already added members
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            child: Text(suggestion[0].toUpperCase()),
                          ),
                          title: Text(suggestion),
                        );
                      },
                      onSelected: (suggestion) {
                        _memberController.text = suggestion;
                        _addMember();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addMember,
                    child: const Text('Hinzufügen'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Mitglieder (${_members.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _members.isEmpty
                    ? const Center(
                        child: Text(
                          'Noch keine Mitglieder hinzugefügt',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(_members[index][0].toUpperCase()),
                              ),
                              title: Text(_members[index]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeMember(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}