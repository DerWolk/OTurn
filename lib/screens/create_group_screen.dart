import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/group.dart';
import '../services/storage_service.dart';
import '../services/text_recognition_service.dart';
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

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectPhotoForExtraction),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () {
                Navigator.pop(context);
                _extractNamesFromPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () {
                Navigator.pop(context);
                _extractNamesFromPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _extractNamesFromPhoto(ImageSource source) async {
    try {
      if (kDebugMode) {
        print('CreateGroupScreen: Starting image selection with source: $source');
      }

      final picker = ImagePicker();

      // Note: Camera should work on mobile web browsers, but has limitations

      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (kDebugMode) {
        print('CreateGroupScreen: Image picked: ${pickedFile?.path}');
      }

      if (pickedFile == null) {
        if (kDebugMode) {
          print('CreateGroupScreen: No image selected');
        }
        return;
      }

      // Crop the image to select specific region
      if (kDebugMode) {
        print('CreateGroupScreen: Starting image cropping');
      }

      CroppedFile? croppedFile;
      try {
        croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: AppLocalizations.of(context)!.selectTextRegion,
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
            ),
            IOSUiSettings(
              title: AppLocalizations.of(context)!.selectTextRegion,
              aspectRatioLockEnabled: false,
              resetAspectRatioEnabled: true,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ],
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
      } catch (cropError) {
        if (kDebugMode) {
          print('CreateGroupScreen: Error during cropping: $cropError');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cropping image: $cropError'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kDebugMode) {
        print('CreateGroupScreen: Cropping result: ${croppedFile?.path}');
      }

      if (croppedFile == null) {
        if (kDebugMode) {
          print('CreateGroupScreen: User cancelled cropping');
        }
        return;
      }

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(AppLocalizations.of(context)!.processingImage),
              ],
            ),
          ),
        );
      }

      // Extract names from cropped image
      if (kDebugMode) {
        print('CreateGroupScreen: Starting OCR on cropped image');
      }

      final file = File(croppedFile.path);
      List<String> extractedNames;

      try {
        extractedNames = await TextRecognitionService.extractNamesFromImage(file);
        if (kDebugMode) {
          print('CreateGroupScreen: OCR extracted ${extractedNames.length} names: $extractedNames');
        }
      } catch (ocrError) {
        if (kDebugMode) {
          print('CreateGroupScreen: OCR error: $ocrError');
        }
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.extractionError),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (extractedNames.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noNamesFound),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show extracted names dialog
      if (mounted) {
        _showExtractedNamesDialog(extractedNames);
      }
    } catch (e) {
      if (kDebugMode) {
        print('CreateGroupScreen: General error in _extractNamesFromPhoto: $e');
      }
      // Close loading dialog if open
      if (mounted) {
        // Try to close loading dialog, but don't fail if it's not open
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          if (kDebugMode) {
            print('CreateGroupScreen: Could not close dialog: $popError');
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.extractionError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExtractedNamesDialog(List<String> extractedNames) {
    List<String> selectedNames = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.extractedNames),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.extractionSuccess(extractedNames.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: extractedNames.length,
                    itemBuilder: (context, index) {
                      final name = extractedNames[index];
                      final isAlreadyMember = _members.contains(name);
                      final isSelected = selectedNames.contains(name);

                      return CheckboxListTile(
                        title: Text(name),
                        subtitle: isAlreadyMember
                            ? Text(
                                AppLocalizations.of(context)!.memberAlreadyInGroup(name),
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              )
                            : null,
                        value: isSelected,
                        enabled: !isAlreadyMember,
                        onChanged: isAlreadyMember ? null : (bool? value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedNames.add(name);
                            } else {
                              selectedNames.remove(name);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: selectedNames.isEmpty ? null : () {
                setState(() {
                  _members.addAll(selectedNames);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.extractionSuccess(selectedNames.length)),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.addExtractedNames),
            ),
          ],
        ),
      ),
    );
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
              const SizedBox(height: 8),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.photo_camera),
                  label: Text(AppLocalizations.of(context)!.extractFromPhoto),
                ),
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