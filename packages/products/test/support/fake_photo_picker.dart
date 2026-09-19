import 'dart:async';
import 'dart:typed_data';

import 'package:products/src/domain/entities/picked_photo.dart';
import 'package:products/src/domain/services/photo_picker.dart';

/// A scriptable [PhotoPicker]: returns [photo] (null = dismissed) after an
/// optional hold.
class FakePhotoPicker implements PhotoPicker {
  PickedPhoto? photo = PickedPhoto(
    bytes: Uint8List.fromList([1, 2, 3]),
    name: 'holiday.jpg',
  );
  int picks = 0;
  Completer<void>? hold;

  @override
  Future<PickedPhoto?> pickFromGallery() async {
    picks++;
    await hold?.future;
    return photo;
  }
}
