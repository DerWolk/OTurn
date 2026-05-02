import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/image_service.dart';

class UniversalImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const UniversalImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return errorWidget ?? const SizedBox.shrink();
    }

    if (kIsWeb) {
      return FutureBuilder<Uint8List?>(
        key: ValueKey(imagePath), // Force rebuild when imagePath changes
        future: ImageService.getImageBytes(imagePath!),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
            );
          } else {
            return errorWidget ?? const SizedBox.shrink();
          }
        },
      );
    } else {
      return Image.file(
        File(imagePath!),
        key: ValueKey(imagePath), // Force rebuild when imagePath changes
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const SizedBox.shrink();
        },
      );
    }
  }
}