import 'package:flutter/material.dart';
import '../models/group.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  final List<String> _members = [];

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

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
      final group = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        members: List.from(_members),
        createdAt: DateTime.now(),
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
        title: const Text('Gruppe erstellen'),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _memberController,
                      decoration: const InputDecoration(
                        labelText: 'Mitglied hinzufügen',
                        hintText: 'Name eingeben',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addMember(),
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