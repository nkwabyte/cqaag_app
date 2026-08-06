import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user supply an image by taking a photo, choosing one from the
/// gallery, or browsing for a file.
///
/// Every image upload in the app needs the same choice, so it is asked once
/// here rather than being reimplemented per screen.
class ImageSourcePicker {
  const ImageSourcePicker._();

  /// Shows a sheet offering camera, gallery and files, then returns the image.
  ///
  /// Returns null if the user dismisses the sheet or picks nothing.
  ///
  /// [useFrontCamera] selects the selfie camera. [allowFiles] can be turned
  /// off where only a photo makes sense.
  ///
  /// Callers pass a plain flag rather than a CameraDevice so screens do not
  /// have to import the picker library just to ask for the front camera.
  static Future<File?> pick(
    BuildContext context, {
    bool useFrontCamera = false,
    String cameraLabel = 'Take a photo',
    String galleryLabel = 'Choose from gallery',
    String fileLabel = 'Choose from files',
    bool allowFiles = true,
  }) async {
    final source = await showModalBottomSheet<_PickSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(cameraLabel),
                onTap: () => Navigator.of(sheetContext).pop(_PickSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(galleryLabel),
                onTap: () => Navigator.of(sheetContext).pop(_PickSource.gallery),
              ),
              if (allowFiles)
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(fileLabel),
                  onTap: () => Navigator.of(sheetContext).pop(_PickSource.file),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    return switch (source) {
      _PickSource.camera => _fromCamera(useFrontCamera),
      _PickSource.gallery => _fromGallery(),
      _PickSource.file => _fromFiles(),
    };
  }

  static Future<File?> _fromCamera(bool useFrontCamera) {
    return _fromImagePicker(
      ImageSource.camera,
      preferredCamera: useFrontCamera ? CameraDevice.front : CameraDevice.rear,
    );
  }

  static Future<File?> _fromGallery() => _fromImagePicker(ImageSource.gallery);

  static Future<File?> _fromImagePicker(
    ImageSource source, {
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    final image = await ImagePicker().pickImage(
      source: source,
      preferredCameraDevice: preferredCamera,
      // Keep uploads small enough for slow connections without making the
      // Ghana Card text unreadable.
      maxWidth: 2000,
      imageQuality: 85,
    );

    return image == null ? null : File(image.path);
  }

  static Future<File?> _fromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final path = result?.files.singleOrNull?.path;
    return path == null ? null : File(path);
  }
}

enum _PickSource { camera, gallery, file }
