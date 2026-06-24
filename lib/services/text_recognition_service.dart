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

      if (kDebugMode) {
        print('TextRecognitionService: Processing image with ML Kit...');
      }

      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (kDebugMode) {
        print('TextRecognitionService: Raw recognized text: "${recognizedText.text}"');
        print('TextRecognitionService: Found ${recognizedText.blocks.length} text blocks');
      }

      List<String> extractedNames = [];

      // Extract text from all text blocks with enhanced processing
      for (TextBlock block in recognizedText.blocks) {
        if (kDebugMode) {
          print('TextRecognitionService: Block text: "${block.text}"');
        }

        for (TextLine line in block.lines) {
          String lineText = line.text.trim();
          if (kDebugMode) {
            print('TextRecognitionService: Line text: "$lineText"');
          }

          if (lineText.isNotEmpty) {
            // Enhanced parsing for handwritten text
            List<String> potentialNames = _parseNamesFromLineEnhanced(lineText);
            extractedNames.addAll(potentialNames);
          }
        }

        // Also try parsing the entire block as one unit (for handwritten lists)
        String blockText = block.text.trim();
        if (blockText.isNotEmpty) {
          List<String> blockNames = _parseNamesFromLineEnhanced(blockText);
          extractedNames.addAll(blockNames);
        }
      }

      if (kDebugMode) {
        print('TextRecognitionService: Extracted potential names: $extractedNames');
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

  static List<String> _parseNamesFromLineEnhanced(String line) {
    List<String> names = [];

    if (kDebugMode) {
      print('TextRecognitionService: Enhanced parsing for: "$line"');
    }

    // Enhanced separators for handwritten text (often imprecise)
    List<String> separators = [
      ',', ';', '\n', '•', '-', '*', '|', ':', '.',
      '/', '\\', '&', '+', '=', '~', '`', '!', '@',
      // Common OCR misreads
      'l', 'I', '1', '/', '\\', '|'
    ];

    String processedLine = line;

    // Special handling for handwritten lists
    // Remove common OCR artifacts
    processedLine = processedLine.replaceAll(RegExp(r'[_~`!@#$%^&*()+=\[\]{}|\\:";\'<>?,./]'), ' ');

    // Handle numbered lists (1. Name, 2. Name, etc.)
    processedLine = processedLine.replaceAll(RegExp(r'^\d+\.?\s*'), '');

    // Handle bullet points and dashes
    processedLine = processedLine.replaceAll(RegExp(r'^[•\-\*\+]\s*'), '');

    // Split by multiple possible separators
    for (String separator in [',', ';', '\n', '  ', '\t']) {
      processedLine = processedLine.replaceAll(separator, '|SPLIT|');
    }

    // Also try splitting by uppercase letters (CamelCase names)
    // But be careful not to split normal names
    processedLine = processedLine.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1|SPLIT|$2');

    List<String> parts = processedLine.split('|SPLIT|');

    // Also try splitting by whitespace if we don't have enough parts
    if (parts.length < 2) {
      List<String> whitespaceParts = line.split(RegExp(r'\s+'));
      if (whitespaceParts.length > parts.length) {
        parts = whitespaceParts;
      }
    }

    for (String part in parts) {
      String cleanedName = _cleanNameEnhanced(part);
      if (cleanedName.isNotEmpty && _isValidNameEnhanced(cleanedName)) {
        names.add(cleanedName);
        if (kDebugMode) {
          print('TextRecognitionService: Found valid name: "$cleanedName"');
        }
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

  static String _cleanNameEnhanced(String name) {
    String cleaned = name.trim();

    // Remove common OCR artifacts and symbols
    cleaned = cleaned.replaceAll(RegExp(r'[_~`!@#$%^&*()+=\[\]{}|\\:";\'<>?,./]'), '');

    // Remove numbers and bullet points from the beginning
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.?\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[•\-\*\+]\s*'), '');

    // Fix common OCR mistakes for German/English names
    cleaned = cleaned.replaceAll('0', 'O'); // Zero to O
    cleaned = cleaned.replaceAll('1', 'I'); // One to I
    cleaned = cleaned.replaceAll('5', 'S'); // Five to S
    cleaned = cleaned.replaceAll('8', 'B'); // Eight to B

    // Remove extra whitespace and normalize
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Capitalize properly (first letter of each word)
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

  static bool _isValidNameEnhanced(String name) {
    // More lenient validation for handwritten text
    if (name.length < 1 || name.length > 50) return false;

    // Must contain at least one letter
    if (!RegExp(r'[a-zA-ZäöüßÄÖÜ]').hasMatch(name)) return false;

    // Shouldn't be all numbers
    if (RegExp(r'^\d+$').hasMatch(name)) return false;

    // Allow more characters but check ratio
    int totalChars = name.length;
    int letterChars = RegExp(r'[a-zA-ZäöüßÄÖÜ]').allMatches(name).length;

    // At least 50% should be letters
    if (letterChars / totalChars < 0.5) return false;

    // Common non-name patterns to reject
    List<String> invalidPatterns = [
      'www', 'http', 'com', 'org', 'de', 'jpg', 'png', 'pdf',
      'email', 'phone', 'tel', 'fax', 'address'
    ];

    String lowerName = name.toLowerCase();
    for (String pattern in invalidPatterns) {
      if (lowerName.contains(pattern)) return false;
    }

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