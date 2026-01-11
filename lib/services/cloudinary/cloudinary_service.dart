import 'dart:io';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
// ignore: implementation_imports
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/transformation/resize/resize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  late final Cloudinary _cloudinary;

  CloudinaryService() {
    _init();
  }

  void _init() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];

    if (cloudName == null || apiKey == null || apiSecret == null) {
      throw Exception('Cloudinary configuration missing in .env');
    }

    // Create a Cloudinary instance and set your cloud name.
    _cloudinary = Cloudinary.fromStringUrl('cloudinary://$apiKey:$apiSecret@$cloudName');
    _cloudinary.config.urlConfig.secure = true;
  }

  Future<String?> uploadAvatar(File file) async {
    try {
      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(
          folder: 'Avatar',
          uniqueFilename: true,
          overwrite: false,
        ),
      );

      if (response?.data?.publicId != null) {
        final publicId = response!.data!.publicId!;

        // Generate a delivery URL for the uploaded image with the desired transformation applied.
        // Resize to 250x250
        String url =
            (_cloudinary.image(publicId)..transformation(
                  Transformation()..resize(
                    Resize.fill()
                      ..width(250)
                      ..height(250),
                  ),
                  // ..effect(Effect.sepia())
                ))
                .toString();

        return url;
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  Future<String?> uploadIdentityDocument(File file) async {
    return _uploadFile(file, folder: 'Identification');
  }

  Future<String?> uploadMembershipDocument(File file) async {
    return _uploadFile(file, folder: 'Members');
  }

  Future<String?> _uploadFile(File file, {required String folder}) async {
    try {
      debugPrint("Attempting to upload file: ${file.path} to folder: $folder");
      if (!file.existsSync()) {
        debugPrint("File does not exist at path: ${file.path}");
        return null;
      }

      final response = await _cloudinary.uploader().upload(
        file,
        params: UploadParams(
          folder: folder,
          uniqueFilename: true,
          overwrite: false,
        ),
      );

      debugPrint("Upload response: ${response?.data?.secureUrl}");
      if (response?.error != null) {
        debugPrint("Upload error from response: ${response?.error?.message}");
      }

      return response?.data?.secureUrl;
    } catch (e, stack) {
      debugPrint('Error uploading to Cloudinary: $e');
      debugPrint('Stack trace: $stack');
      return null;
    }
  }
}
