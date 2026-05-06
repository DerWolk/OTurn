import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Migrate existing images from Documents to Support directory
  static Future<void> migrateImages() async {
    if (kIsWeb) return; // Skip migration on web platform

    try {
      final Directory newSupportDir = await getApplicationSupportDirectory();
      final String newImagesDir = path.join(newSupportDir.path, 'images');
      final Directory newImagesDirObj = Directory(newImagesDir);

      if (!await newImagesDirObj.exists()) {
        await newImagesDirObj.create(recursive: true);
      }

      if (kDebugMode) {
        print('ImageService: Current app support dir: ${newSupportDir.path}');
      }

      // Try to migrate from Documents directory
      await _migrateFromDirectory(await getApplicationDocumentsDirectory(), newImagesDir);

      // On iOS, search for images in all possible container directories
      if (Platform.isIOS) {
        await _migrateFromAllContainers(newImagesDir);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating images: $e');
      }
    }
  }

  /// Search for images in all possible iOS container directories
  static Future<void> _migrateFromAllContainers(String targetImagesDir) async {
    try {
      // Get the base containers directory
      final Directory appSupportDir = await getApplicationSupportDirectory();
      // Navigate up to find other container directories
      // Path structure: /var/mobile/Containers/Data/Application/{UUID}/Library/Application Support
      final containerBasePath = appSupportDir.path.split('/Library/Application Support')[0];
      final parentPath = Directory(containerBasePath).parent.path;

      if (kDebugMode) {
        print('ImageService: Searching in container parent: $parentPath');
      }

      final Directory parentDir = Directory(parentPath);
      if (await parentDir.exists()) {
        await for (final FileSystemEntity entity in parentDir.list()) {
          if (entity is Directory) {
            // Check each container directory for images
            final supportDir = Directory(path.join(entity.path, 'Library', 'Application Support', 'images'));
            final documentsDir = Directory(path.join(entity.path, 'Documents', 'images'));

            if (await supportDir.exists()) {
              if (kDebugMode) {
                print('ImageService: Found old images in: ${supportDir.path}');
              }
              await _migrateFromSpecificDirectory(supportDir, targetImagesDir);
            }

            if (await documentsDir.exists()) {
              if (kDebugMode) {
                print('ImageService: Found old images in: ${documentsDir.path}');
              }
              await _migrateFromSpecificDirectory(documentsDir, targetImagesDir);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching containers: $e');
      }
    }
  }

  /// Helper method to migrate images from a specific directory
  static Future<void> _migrateFromDirectory(Directory sourceDir, String targetImagesDir) async {
    final String sourceImagesDir = path.join(sourceDir.path, 'images');
    final Directory sourceImagesDirObj = Directory(sourceImagesDir);

    if (!await sourceImagesDirObj.exists()) return;

    await _migrateFromSpecificDirectory(sourceImagesDirObj, targetImagesDir);
  }

  /// Migrate images from a specific images directory
  static Future<void> _migrateFromSpecificDirectory(Directory sourceImagesDir, String targetImagesDir) async {
    if (!await sourceImagesDir.exists()) return;

    try {
      await for (final file in sourceImagesDir.list()) {
        if (file is File && file.path.contains('img_')) {
          final String fileName = path.basename(file.path);
          final String newPath = path.join(targetImagesDir, fileName);

          // Only copy if file doesn't already exist in new location
          if (!await File(newPath).exists()) {
            await file.copy(newPath);
            if (kDebugMode) {
              print('ImageService: Migrated image: $fileName from ${sourceImagesDir.path}');
            }
          } else {
            if (kDebugMode) {
              print('ImageService: Image already exists: $fileName');
            }
          }

          // Delete original file after successful copy
          await file.delete();
        }
      }

      // Remove old directory if empty
      if (await sourceImagesDir.exists()) {
        final contents = await sourceImagesDir.list().toList();
        if (contents.isEmpty) {
          await sourceImagesDir.delete();
          if (kDebugMode) {
            print('ImageService: Removed empty directory: ${sourceImagesDir.path}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error migrating from ${sourceImagesDir.path}: $e');
      }
    }
  }

  /// Pick an image from gallery or camera
  static Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Save image to app directory
      final String savedPath = await _saveImageToAppDirectory(image);
      return savedPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }

  /// Save image to app's support directory (persistent across updates)
  static Future<String> _saveImageToAppDirectory(XFile image) async {
    if (kIsWeb) {
      // For web, store the image data in SharedPreferences as base64
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String imageId = 'img_$timestamp';

      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('image_$imageId', base64Image);

      return imageId; // Return the ID instead of path
    }

    final Directory appSupportDir = await getApplicationSupportDirectory();
    final String imagesDir = path.join(appSupportDir.path, 'images');

    // Create images directory if it doesn't exist
    final Directory imagesDirObj = Directory(imagesDir);
    if (!await imagesDirObj.exists()) {
      await imagesDirObj.create(recursive: true);
    }

    // Generate unique filename
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String extension = path.extension(image.path);
    final String fileName = 'img_$timestamp$extension';
    final String savedPath = path.join(imagesDir, fileName);

    // Copy file
    await File(image.path).copy(savedPath);

    return savedPath;
  }

  /// Delete an image file
  static Future<bool> deleteImage(String imagePath) async {
    try {
      if (kDebugMode) {
        print('Attempting to delete image: $imagePath');
      }

      if (kIsWeb) {
        // On web, delete from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final success = await prefs.remove('image_$imagePath');
        if (kDebugMode) {
          print('Web platform: Deleted image $imagePath from storage: $success');
        }
        return success;
      }

      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('iOS/Android: Successfully deleted file: $imagePath');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('iOS/Android: File does not exist: $imagePath');
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      return false;
    }
  }

  /// Check if image file exists
  static Future<bool> imageExists(String imagePath) async {
    try {
      if (kIsWeb) {
        // On web, check if the image exists in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey('image_$imagePath');
      }

      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get image file
  static File? getImageFile(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    return File(imagePath);
  }

  /// Get image bytes for web platform
  static Future<Uint8List?> getImageBytes(String imageId) async {
    if (!kIsWeb) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? base64Image = prefs.getString('image_$imageId');
      if (base64Image != null) {
        return base64Decode(base64Image);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image bytes: $e');
      }
    }
    return null;
  }

  /// Get the current images directory path
  static Future<String> getCurrentImagesDirectory() async {
    if (kIsWeb) {
      return 'web_storage'; // For web, we use SharedPreferences
    }

    final Directory appSupportDir = await getApplicationSupportDirectory();
    return path.join(appSupportDir.path, 'images');
  }

  /// Show image source selection dialog
  static Future<String?> showImageSourceDialog() async {
    // This would be implemented in the UI layer
    // For now, we'll default to gallery
    return await pickImage(source: ImageSource.gallery);
  }
}