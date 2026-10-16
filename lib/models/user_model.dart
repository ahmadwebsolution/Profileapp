import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory UserModel.fromFirebaseUser(User user, {String? customPhotoUrl}) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.email?.split('@').first ?? 'User'),
      photoUrl: customPhotoUrl ?? user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime? created;
    if (map['createdAt'] is Timestamp) {
      created = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      created = DateTime.tryParse(map['createdAt']);
    }

    return UserModel(
      id: docId,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
