import 'package:image_picker/image_picker.dart';
import 'package:products/src/domain/entities/picked_photo.dart';
import 'package:products/src/domain/services/photo_picker.dart';

/// [PhotoPicker] backed by the platform photo picker. Photos are downscaled
/// and recompressed before upload: a phone photo is many megabytes, and the
/// product cards never show more than a screen's width.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return PickedPhoto(bytes: await file.readAsBytes(), name: file.name);
  }
}
