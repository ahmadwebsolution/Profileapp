import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/note_repository.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteRepository _noteRepository;

  String? _userId;
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  StreamSubscription<List<NoteModel>>? _notesSubscription;

  NoteViewModel({NoteRepository? noteRepository})
      : _noteRepository = noteRepository ?? NoteRepository();

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Initialize or update user subscription
  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (_userId != null) {
      _subscribeToNotes();
    } else {
      _notesSubscription?.cancel();
      _notes = [];
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _subscribeToNotes();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _subscribeToNotes();
  }

  void _subscribeToNotes() {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    _notesSubscription?.cancel();
    _notesSubscription = _noteRepository
        .streamNotes(
          _userId!,
          category: _selectedCategory,
          searchQuery: _searchQuery,
        )
        .listen(
          (notesList) {
            _notes = notesList;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // CREATE Note
  Future<bool> addNote({
    required String title,
    required String content,
    String category = 'General',
    int colorValue = 0xFF6366F1,
  }) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      final newNote = NoteModel(
        id: '',
        userId: _userId!,
        title: title.trim(),
        content: content.trim(),
        category: category,
        colorValue: colorValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _noteRepository.addNote(newNote);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add note: $e';
      notifyListeners();
      return false;
    }
  }

  // UPDATE Note
  Future<bool> updateNote({
    required String noteId,
    required String title,
    required String content,
    String? category,
    int? colorValue,
  }) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      await _noteRepository.updateNote(
        userId: _userId!,
        noteId: noteId,
        title: title.trim(),
        content: content.trim(),
        category: category,
        colorValue: colorValue,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
      notifyListeners();
      return false;
    }
  }

  // DELETE Note
  Future<bool> deleteNote(String noteId) async {
    if (_userId == null) {
      _errorMessage = 'User not authenticated.';
      notifyListeners();
      return false;
    }

    try {
      await _noteRepository.deleteNote(_userId!, noteId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
