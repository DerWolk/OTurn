import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  static final TextRecognizer _textRecognizer = TextRecognizer();

  static Future<List<String>> extractNamesFromImage(File imageFile) async {
    try {
      // Use ML Kit for reliable cross-platform OCR
      return await _extractWithMLKit(imageFile);
    } catch (e) {
      throw Exception('Error extracting text from image: $e');
    }
  }


  static Future<List<String>> _extractWithMLKit(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      List<String> extractedNames = [];

      // Extract text from all text blocks
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text.trim();
          if (lineText.isNotEmpty) {
            // Split by common separators and clean up
            List<String> potentialNames = _parseNamesFromLine(lineText);
            extractedNames.addAll(potentialNames);
          }
        }
      }

      // Clean and filter names
      return _cleanAndFilterNames(extractedNames);
    } catch (e) {
      throw Exception('ML Kit OCR failed: $e');
    }
  }

  static List<String> _parseNamesFromLine(String line) {
    List<String> names = [];

    // Common separators for names in lists
    List<String> separators = [',', ';', '\n', '•', '-', '*', '|'];

    String processedLine = line;

    // Replace separators with commas for consistent splitting
    for (String separator in separators) {
      processedLine = processedLine.replaceAll(separator, ',');
    }

    // Split by comma and process each potential name
    List<String> parts = processedLine.split(',');

    for (String part in parts) {
      String cleanedName = _cleanName(part);
      if (cleanedName.isNotEmpty && _isValidName(cleanedName)) {
        names.add(cleanedName);
      }
    }

    return names;
  }

  static String _cleanName(String name) {
    // Remove common prefixes and suffixes
    String cleaned = name.trim();

    // Remove common list markers
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.?\s*'), ''); // Numbers like "1. "
    cleaned = cleaned.replaceAll(RegExp(r'^[•\-\*]\s*'), ''); // Bullet points

    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Capitalize first letter of each word
    if (cleaned.isNotEmpty) {
      List<String> words = cleaned.split(' ');
      words = words.map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return word;
      }).toList();
      cleaned = words.join(' ');
    }

    return cleaned;
  }

  static bool _isValidName(String name) {
    // Basic validation for potential names
    if (name.length < 2 || name.length > 50) return false;

    // Must contain at least one letter
    if (!RegExp(r'[a-zA-ZäöüßÄÖÜ]').hasMatch(name)) return false;

    // Shouldn't be all numbers
    if (RegExp(r'^\d+$').hasMatch(name)) return false;

    // Shouldn't contain too many special characters
    if (RegExp(r"[^\w\säöüßÄÖÜ\-\']").allMatches(name).length > 2) return false;

    return true;
  }

  static List<String> _cleanAndFilterNames(List<String> names) {
    // Remove duplicates and empty strings
    Set<String> uniqueNames = <String>{};

    for (String name in names) {
      if (name.isNotEmpty && name.length >= 2) {
        uniqueNames.add(name);
      }
    }

    List<String> result = uniqueNames.toList();
    result.sort(); // Sort alphabetically

    return result;
  }

  static void dispose() {
    _textRecognizer.close();
  }
}