import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore;

  NoteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Reference to user's notes subcollection: /users/{userId}/notes
  CollectionReference<Map<String, dynamic>> _notesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('notes');
  }

  // 1. CREATE: Add a note using .add()
  Future<String> addNote(NoteModel note) async {
    final docRef = await _notesCollection(note.userId).add(note.toMap());
    return docRef.id;
  }

  // 1b. CREATE / OVERWRITE: Set a note with specific ID using .set()
  Future<void> setNote(NoteModel note) async {
    await _notesCollection(note.userId).doc(note.id).set(
          note.toMap(),
          SetOptions(merge: true),
        );
  }

  // 2. READ (Real-time): Stream notes using .snapshots() with .orderBy() & optional .where()
  Stream<List<NoteModel>> streamNotes(
    String userId, {
    String? category,
    String? searchQuery,
  }) {
    Query<Map<String, dynamic>> query = _notesCollection(userId)
        .orderBy('updatedAt', descending: true);

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      final notes = snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.toLowerCase().trim();
        return notes.where((note) {
          return note.title.toLowerCase().contains(queryLower) ||
              note.content.toLowerCase().contains(queryLower);
        }).toList();
      }
      return notes;
    });
  }

  // 2b. READ (One-time): Fetch notes snapshot once using .get()
  Future<List<NoteModel>> getNotesOnce(String userId, {int limit = 20}) async {
    final snapshot = await _notesCollection(userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  // 3. UPDATE: Update specific fields using .update()
  Future<void> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required String content,
    String? category,
    int? colorValue,
  }) async {
    final Map<String, dynamic> updates = {
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (category != null) updates['category'] = category;
    if (colorValue != null) updates['colorValue'] = colorValue;

    await _notesCollection(userId).doc(noteId).update(updates);
  }

  // 4. DELETE: Delete document using .delete()
  Future<void> deleteNote(String userId, String noteId) async {
    await _notesCollection(userId).doc(noteId).delete();
  }
}
