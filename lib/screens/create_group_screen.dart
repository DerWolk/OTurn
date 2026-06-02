import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../widgets/image_picker_widget.dart';
import '../l10n/app_localizations.dart';

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
    if (name.isEmpty) {
      return;
    }

    if (_members.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.memberAlreadyInGroup(name)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _members.add(name);
      _memberController.clear();
    });
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
        SnackBar(content: Text(AppLocalizations.of(context)!.addAtLeastOneMemberError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_isEditing ? AppLocalizations.of(context)!.editGroup : AppLocalizations.of(context)!.createGroup),
        actions: [
          TextButton(
            onPressed: _saveGroup,
            child: Text(AppLocalizations.of(context)!.save),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupName,
                  hintText: AppLocalizations.of(context)!.groupNameHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.groupNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ImagePickerWidget(
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
                  placeholder: AppLocalizations.of(context)!.groupImage,
                  placeholderIcon: Icons.group,
                ),
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
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.addMember,
                            hintText: AppLocalizations.of(context)!.memberNameHint,
                            border: const OutlineInputBorder(),
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
                    child: Text(AppLocalizations.of(context)!.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.membersCount(_members.length),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _members.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noMembersAddedYet,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
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