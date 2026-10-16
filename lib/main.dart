import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/storage_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'views/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the existing platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NotesProfileApp());
}

class NoRubberScrollBehavior extends MaterialScrollBehavior {
  const NoRubberScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Removes rubber stretch overscroll effect completely
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class NotesProfileApp extends StatelessWidget {
  const NotesProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate repositories
    final authRepository = AuthRepository();
    final noteRepository = NoteRepository();
    final storageRepository = StorageRepository();

    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<NoteRepository>.value(value: noteRepository),
        Provider<StorageRepository>.value(value: storageRepository),
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider<NoteViewModel>(
          create: (_) => NoteViewModel(noteRepository: noteRepository),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(
            storageRepository: storageRepository,
            authRepository: authRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NoteNest',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const NoRubberScrollBehavior(),
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
