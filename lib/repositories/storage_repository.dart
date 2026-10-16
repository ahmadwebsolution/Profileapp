import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageRepository {
  final FirebaseStorage _storage;
  final ImagePicker _picker;

  StorageRepository({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  // Pick an image from Camera or Gallery
  Future<XFile?> pickImage({required ImageSource source}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  // Upload profile image bytes to Firebase Storage and return the public download URL
  Future<String> uploadProfileImage({
    required String userId,
    required XFile file,
  }) async {
    final Uint8List data = await file.readAsBytes();
    final String extension = file.name.split('.').lastOrNull ?? 'jpg';
    final String path = 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$extension';

    final Reference ref = _storage.ref().child(path);
    final SettableMetadata metadata = SettableMetadata(
      contentType: 'image/$extension',
      customMetadata: {'uploadedBy': userId},
    );

    final UploadTask uploadTask = ref.putData(data, metadata);
    final TaskSnapshot snapshot = await uploadTask;

    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Delete image by URL if necessary
  Future<void> deleteImageByUrl(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {
      // Ignore if file doesn't exist
    }
  }
}
