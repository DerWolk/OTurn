import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/group.dart';
import '../models/task.dart';
import 'image_service.dart';

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
    print('StorageService: Saving group ${group.name} with imagePath: ${group.imagePath}');
    final json = group.toJson();
    print('StorageService: JSON: $json');
    final jsonString = jsonEncode(json);
    await _groupsBoxInstance.put(group.id, jsonString);
    print('StorageService: Group saved to Hive with key: ${group.id}');
  }

  static Future<void> deleteGroup(String groupId) async {
    final group = getGroup(groupId);
    if (group?.imagePath != null) {
      await ImageService.deleteImage(group!.imagePath!);
    }
    await _groupsBoxInstance.delete(groupId);
  }

  static List<Group> getAllGroups() {
    print('StorageService: getAllGroups() called');
    final groups = <Group>[];
    for (final key in _groupsBoxInstance.keys) {
      final jsonString = _groupsBoxInstance.get(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final group = Group.fromJson(json);
          print('StorageService: Loaded group ${group.name} with imagePath: ${group.imagePath}');
          groups.add(group);
        } catch (e) {
          print('Error parsing group $key: $e');
        }
      }
    }
    print('StorageService: Returning ${groups.length} groups');
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
    final task = getTask(taskId);
    if (task?.imagePath != null) {
      await ImageService.deleteImage(task!.imagePath!);
    }
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

  /// Clean up invalid image paths in groups and tasks
  static Future<void> cleanupInvalidImages() async {
    try {
      print('StorageService: Starting cleanup of invalid images');

      // Clean up groups
      final groups = getAllGroups();
      bool groupsUpdated = false;
      for (final group in groups) {
        if (group.imagePath != null) {
          final exists = await ImageService.imageExists(group.imagePath!);
          if (!exists) {
            print('StorageService: Image not found for group ${group.name}: ${group.imagePath}');

            // Try to find the image with a new path
            final newPath = await _findMigratedImagePath(group.imagePath!);
            if (newPath != null) {
              print('StorageService: Found migrated image for ${group.name}: $newPath');
              final updatedGroup = group.copyWith(imagePath: newPath);
              await saveGroup(updatedGroup);
              groupsUpdated = true;
            } else {
              print('StorageService: Removing invalid image path for group ${group.name}');
              final cleanedGroup = group.copyWith(clearImagePath: true);
              await saveGroup(cleanedGroup);
              groupsUpdated = true;
            }
          }
        }
      }

      // Clean up tasks
      final tasks = getAllTasks();
      bool tasksUpdated = false;
      for (final task in tasks) {
        if (task.imagePath != null) {
          final exists = await ImageService.imageExists(task.imagePath!);
          if (!exists) {
            print('StorageService: Image not found for task ${task.name}: ${task.imagePath}');

            // Try to find the image with a new path
            final newPath = await _findMigratedImagePath(task.imagePath!);
            if (newPath != null) {
              print('StorageService: Found migrated image for ${task.name}: $newPath');
              final updatedTask = task.copyWith(imagePath: newPath);
              await saveTask(updatedTask);
              tasksUpdated = true;
            } else {
              print('StorageService: Removing invalid image path for task ${task.name}');
              final cleanedTask = task.copyWith(clearImagePath: true);
              await saveTask(cleanedTask);
              tasksUpdated = true;
            }
          }
        }
      }

      if (groupsUpdated || tasksUpdated) {
        print('StorageService: Image cleanup completed with updates');
      } else {
        print('StorageService: Image cleanup completed - no updates needed');
      }
    } catch (e) {
      print('Error cleaning up invalid images: $e');
    }
  }

  /// Try to find an image with the current container path
  static Future<String?> _findMigratedImagePath(String oldPath) async {
    try {
      // Extract the filename from the old path
      final fileName = oldPath.split('/').last;
      if (!fileName.startsWith('img_')) return null;

      // Get current images directory
      final newImagesDir = await ImageService.getCurrentImagesDirectory();
      final newPath = path.join(newImagesDir, fileName);

      // Check if the image exists in the new location
      final exists = await ImageService.imageExists(newPath);
      return exists ? newPath : null;
    } catch (e) {
      print('Error finding migrated image path: $e');
      return null;
    }
  }

  static Future<void> clearAll() async {
    try {
      // Clear all groups
      await _groupsBoxInstance.clear();

      // Clear all tasks
      await _tasksBoxInstance.clear();

      print('StorageService: All data cleared successfully');
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }
}