import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';
import 'home_view.dart';
import 'login_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // Pass the user ID to the NoteViewModel so real-time notes stream activates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final noteViewModel = context.read<NoteViewModel>();
      noteViewModel.setUserId(authViewModel.currentUser?.uid);
    });

    if (authViewModel.currentUser != null) {
      return const HomeView();
    } else {
      return const LoginView();
    }
  }
}
