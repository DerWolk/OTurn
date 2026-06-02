import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import 'universal_image.dart';
import '../l10n/app_localizations.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? imagePath;
  final Function(String?) onImageSelected;
  final double size;
  final String placeholder;
  final IconData placeholderIcon;

  const ImagePickerWidget({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.size = 100,
    this.placeholder = 'Add image',
    this.placeholderIcon = Icons.add_a_photo,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  @override
  void didUpdateWidget(ImagePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      _currentImagePath = widget.imagePath;
    }
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.selectImage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImageSourceOption(
                    icon: Icons.photo_library,
                    label: kIsWeb ? AppLocalizations.of(context)!.chooseFile : AppLocalizations.of(context)!.gallery,
                    onTap: () async {
                      Navigator.pop(context);
                      final imagePath = await ImageService.pickImage(
                        source: ImageSource.gallery,
                      );
                      setState(() {
                        _currentImagePath = imagePath;
                      });
                      widget.onImageSelected(imagePath);
                    },
                  ),
                  if (_currentImagePath != null)
                    _ImageSourceOption(
                      icon: Icons.delete,
                      label: AppLocalizations.of(context)!.remove,
                      color: Colors.red,
                      onTap: () async {
                        Navigator.pop(context);
                        if (_currentImagePath != null) {
                          if (kDebugMode) {
                            print('ImagePickerWidget: Deleting image: $_currentImagePath');
                          }
                          final success = await ImageService.deleteImage(_currentImagePath!);
                          if (kDebugMode) {
                            print('ImagePickerWidget: Delete success: $success');
                          }
                        }
                        setState(() {
                          _currentImagePath = null;
                        });
                        if (kDebugMode) {
                          print('ImagePickerWidget: Calling onImageSelected(null)');
                        }
                        widget.onImageSelected(null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: _currentImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: UniversalImage(
                  key: ValueKey(_currentImagePath),
                  imagePath: _currentImagePath,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.cover,
                  errorWidget: _PlaceholderContent(
                    icon: Icons.broken_image,
                    text: AppLocalizations.of(context)!.imageNotFound,
                    size: widget.size,
                  ),
                ),
              )
            : _PlaceholderContent(
                icon: widget.placeholderIcon,
                text: widget.placeholder,
                size: widget.size,
              ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: effectiveColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: effectiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final IconData icon;
  final String text;
  final double size;

  const _PlaceholderContent({
    required this.icon,
    required this.text,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: size * 0.3,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size * 0.12,
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}