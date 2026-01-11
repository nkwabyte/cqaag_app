import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'cloudinary_service.dart';

part 'cloudinary_provider.g.dart';

@Riverpod(keepAlive: true)
CloudinaryService cloudinaryService(Ref ref) {
  return CloudinaryService();
}
