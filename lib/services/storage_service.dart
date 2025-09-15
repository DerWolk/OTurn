import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/group.dart';
import '../models/task.dart';

class StorageService {
  static const String _groupsBox = 'groups';
  static const String _tasksBox = 'tasks';

  static late Box<String> _groupsBoxInstance;
  static late Box<String> _tasksBoxInstance;

  static Future<void> init() async {
    await Hive.initFlutter();

    _groupsBoxInstance = await Hive.openBox<String>(_groupsBox);
    _tasksBoxInstance = await Hive.openBox<String>(_tasksBox);
  }

  // Groups
  static Future<void> saveGroup(Group group) async {
    final json = group.toJson();
    final jsonString = jsonEncode(json);
    await _groupsBoxInstance.put(group.id, jsonString);
  }

  static Future<void> deleteGroup(String groupId) async {
    await _groupsBoxInstance.delete(groupId);
  }

  static List<Group> getAllGroups() {
    final groups = <Group>[];
    for (final key in _groupsBoxInstance.keys) {
      final jsonString = _groupsBoxInstance.get(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          groups.add(Group.fromJson(json));
        } catch (e) {
          print('Error parsing group $key: $e');
        }
      }
    }
    return groups;
  }

  static Group? getGroup(String groupId) {
    final jsonString = _groupsBoxInstance.get(groupId);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Group.fromJson(json);
      } catch (e) {
        print('Error parsing group $groupId: $e');
        return null;
      }
    }
    return null;
  }

  // Tasks
  static Future<void> saveTask(Task task) async {
    final json = task.toJson();
    final jsonString = jsonEncode(json);
    await _tasksBoxInstance.put(task.id, jsonString);
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksBoxInstance.delete(taskId);
  }

  static List<Task> getAllTasks() {
    final tasks = <Task>[];
    for (final key in _tasksBoxInstance.keys) {
      final jsonString = _tasksBoxInstance.get(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          tasks.add(Task.fromJson(json));
        } catch (e) {
          print('Error parsing task $key: $e');
        }
      }
    }
    return tasks;
  }

  static Task? getTask(String taskId) {
    final jsonString = _tasksBoxInstance.get(taskId);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return Task.fromJson(json);
      } catch (e) {
        print('Error parsing task $taskId: $e');
        return null;
      }
    }
    return null;
  }

  // Utility methods
  static List<String> getAllUniqueMembers() {
    final allMembers = <String>{};

    // Get all members from groups
    final groups = getAllGroups();
    for (final group in groups) {
      allMembers.addAll(group.members);
    }

    // Get all members from tasks
    final tasks = getAllTasks();
    for (final task in tasks) {
      allMembers.addAll(task.additionalMembers);
      for (final history in task.history) {
        allMembers.addAll(history.participants);
      }
    }

    final sortedMembers = allMembers.toList()..sort();
    return sortedMembers;
  }
}