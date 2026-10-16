import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'General',
    'Work',
    'Personal',
    'Ideas',
    'Tasks',
  ];

  final List<int> _cardColors = const [
    0xFF6366F1, // Indigo
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEC4899, // Pink
    0xFF3B82F6, // Blue
    0xFF8B5CF6, // Purple
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet(String userId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadImage(userId, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.purple),
                ),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _uploadImage(userId, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadImage(String userId, ImageSource source) async {
    final profileVM = context.read<ProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final success = await profileVM.pickAndUploadProfilePicture(
      userId: userId,
      source: source,
    );

    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(profileVM.successMessage ?? 'Photo uploaded successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (profileVM.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(profileVM.errorMessage!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditProfileDialog(UserModel user) {
    final nameController = TextEditingController(text: user.displayName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              final profileVM = context.read<ProfileViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              final success = await profileVM.updateDisplayName(
                userId: user.id,
                newName: newName,
              );
              if (!mounted) return;
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Profile name updated!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNoteBottomSheet({NoteModel? note}) {
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedCategory = note?.category ?? 'General';
    int selectedColor = note?.colorValue ?? _cardColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEditing ? 'Edit Note' : 'Create New Note',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter note title...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Write your thoughts...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.where((c) => c != 'All').map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() => selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Card Accent Color', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: _cardColors.map((colorVal) {
                      final isSelected = selectedColor == colorVal;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = colorVal),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(colorVal),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black87 : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final content = contentController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a note title'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        final noteVM = context.read<NoteViewModel>();
                        final messenger = ScaffoldMessenger.of(context);
                        final bool ok;
                        if (isEditing) {
                          ok = await noteVM.updateNote(
                            noteId: note.id,
                            title: title,
                            content: content,
                            category: selectedCategory,
                            colorValue: selectedColor,
                          );
                        } else {
                          ok = await noteVM.addNote(
                            title: title,
                            content: content,
                            category: selectedCategory,
                            colorValue: selectedColor,
                          );
                        }

                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? (isEditing ? 'Note updated!' : 'Note created!')
                                  : (noteVM.errorMessage ?? 'Operation failed'),
                            ),
                            backgroundColor: ok ? Colors.green : Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isEditing ? 'Update Note' : 'Add Note',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteNote(NoteModel note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final noteVM = context.read<NoteViewModel>();
              final messenger = ScaffoldMessenger.of(context);
              final ok = await noteVM.deleteNote(note.id);
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Note deleted' : (noteVM.errorMessage ?? 'Failed')),
                  backgroundColor: ok ? Colors.black87 : Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showProfileDrawerOrSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    if (profileVM.isUploading)
                      const Positioned.fill(
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showImagePickerSheet(user.id);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Display Name'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditProfileDialog(user);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Update Profile Picture'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showImagePickerSheet(user.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final authVM = context.read<AuthViewModel>();
                    await authVM.logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final noteVM = context.watch<NoteViewModel>();
    final profileVM = context.watch<ProfileViewModel>();

    final user = authVM.userProfile ??
        (authVM.currentUser != null
            ? UserModel.fromFirebaseUser(authVM.currentUser!)
            : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NoteNest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () => _showProfileDrawerOrSheet(user),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                          ? Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    if (profileVM.isUploading)
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => noteVM.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search notes by title or content...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          noteVM.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Chips Bar
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = noteVM.selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => noteVM.setCategory(cat),
                    selectedColor: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Real-time Notes List or State
          Expanded(
            child: noteVM.isLoading && noteVM.notes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : noteVM.notes.isEmpty
                    ? _buildEmptyState(theme)
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Real-time listener keeps it synced automatically
                          await Future.delayed(const Duration(milliseconds: 300));
                        },
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: noteVM.notes.length,
                          itemBuilder: (ctx, index) {
                            final note = noteVM.notes[index];
                            return _buildNoteCard(ctx, note, theme);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteBottomSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.note_alt_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Notes Found',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _searchController.text.isNotEmpty
                    ? 'Try searching with a different keyword.'
                    : 'Tap the + Add Note button below to create your first Firestore note!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note, ThemeData theme) {
    final noteColor = Color(note.colorValue);
    final formattedDate =
        '${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: noteColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showNoteBottomSheet(note: note),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Category Tag & Timestamp & Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: noteColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: noteColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDeleteNote(note),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Note Title
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Note Content
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
