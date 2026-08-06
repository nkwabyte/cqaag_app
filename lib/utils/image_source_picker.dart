import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Lets the user supply an image either by taking a photo or by choosing an
/// existing file.
///
/// Every document upload in the app needs both routes, so the choice is asked
/// once here rather than being duplicated per screen.
class ImageSourcePicker {
  const ImageSourcePicker._();

  /// Shows a sheet offering camera or file, then returns the chosen image.
  ///
  /// Returns null if the user dismisses the sheet or picks nothing.
  static Future<File?> pick(
    BuildContext context, {
    CameraDevice preferredCamera = CameraDevice.rear,
    String cameraLabel = 'Take a photo',
    String fileLabel = 'Choose from files',
  }) async {
    final source = await showModalBottomSheet<_ImageSource>(
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
                onTap: () => Navigator.of(sheetContext).pop(_ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(fileLabel),
                onTap: () => Navigator.of(sheetContext).pop(_ImageSource.file),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    return switch (source) {
      _ImageSource.camera => _fromCamera(preferredCamera),
      _ImageSource.file => _fromFiles(),
    };
  }

  static Future<File?> _fromCamera(CameraDevice preferredCamera) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.camera,
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

enum _ImageSource { camera, file }
