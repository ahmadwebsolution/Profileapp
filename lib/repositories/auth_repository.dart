import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Sign up with Email and Password
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? email.trim(),
        displayName: displayName?.trim() ?? (user.email?.split('@').first ?? 'User'),
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(
            userModel.toMap(),
            SetOptions(merge: true),
          );
    }

    return credential;
  }

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Sync user data to Firestore if not exists
    final user = credential.user;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final userModel = UserModel.fromFirebaseUser(user);
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      }
    }

    return credential;
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      final String? idToken = account.authentication.idToken;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? account.email,
            displayName: user.displayName ?? account.displayName ?? 'Google User',
            photoUrl: user.photoURL ?? account.photoUrl,
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(
                userModel.toMap(),
                SetOptions(merge: true),
              );
        }
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore if not signed in via Google
    }
    await _auth.signOut();
  }

  // Stream current user profile document from Firestore
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    });
  }

  // Get user profile once
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // Update user profile info in Firestore & Auth
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestore.collection('users').doc(uid).set(updates, SetOptions(merge: true));

    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
