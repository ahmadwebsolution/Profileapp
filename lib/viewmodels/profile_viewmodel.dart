import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/auth_repository.dart';
import '../repositories/storage_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  bool _isUploading = false;
  String? _errorMessage;
  String? _successMessage;

  ProfileViewModel({
    StorageRepository? storageRepository,
    AuthRepository? authRepository,
  })  : _storageRepository = storageRepository ?? StorageRepository(),
        _authRepository = authRepository ?? AuthRepository();

  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Pick from Camera/Gallery, upload to Firebase Storage, and update Firestore & FirebaseAuth
  Future<bool> pickAndUploadProfilePicture({
    required String userId,
    required ImageSource source,
  }) async {
    _setUploading(true);
    _errorMessage = null;
    _successMessage = null;

    try {
      final XFile? image = await _storageRepository.pickImage(source: source);
      if (image == null) {
        // User cancelled picker
        _setUploading(false);
        return false;
      }

      // 1. Upload to Firebase Storage & get download URL
      final String downloadUrl = await _storageRepository.uploadProfileImage(
        userId: userId,
        file: image,
      );

      // 2. Save reference URL inside Firestore user document and FirebaseAuth profile
      await _authRepository.updateUserProfile(
        uid: userId,
        photoUrl: downloadUrl,
      );

      _successMessage = 'Profile picture updated successfully!';
      _setUploading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload image: $e';
      _setUploading(false);
      return false;
    }
  }

  // Update display name
  Future<bool> updateDisplayName({
    required String userId,
    required String newName,
  }) async {
    if (newName.trim().isEmpty) return false;
    _setUploading(true);
    _errorMessage = null;
    try {
      await _authRepository.updateUserProfile(
        uid: userId,
        displayName: newName.trim(),
      );
      _successMessage = 'Name updated successfully!';
      _setUploading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update name: $e';
      _setUploading(false);
      return false;
    }
  }
}
