import 'package:products/src/domain/entities/picked_photo.dart';

/// Lets the user choose a photo. An interface so the form bloc can be tested
/// without the platform picker.
abstract interface class PhotoPicker {
  /// Null when the user dismissed the picker without choosing.
  Future<PickedPhoto?> pickFromGallery();
}
