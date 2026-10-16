import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserModel?>? _profileSubscription;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _initAuthListener();
  }

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initAuthListener() {
    _currentUser = _authRepository.currentUser;
    if (_currentUser != null) {
      _listenToProfile(_currentUser!.uid);
    }

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _listenToProfile(user.uid);
      } else {
        _profileSubscription?.cancel();
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  void _listenToProfile(String uid) {
    _profileSubscription?.cancel();
    _profileSubscription = _authRepository.streamUserProfile(uid).listen((profile) {
      _userProfile = profile;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Email/Password Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Email/Password Signup
  Future<bool> register(String email, String password, String displayName) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final credential = await _authRepository.signInWithGoogle();
      _setLoading(false);
      return credential != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authRepository.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthError(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password provided is too weak (min 6 characters).';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
