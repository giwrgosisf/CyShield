import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kids_app/bloc/pair/pairing_screen_cubit.dart';
import 'package:kids_app/core/services/pairing_service.dart';


import '../../data/repositories/kid_repository.dart';
import '../core/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/pairing_screen.dart';

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final user = snap.data;

        if (user == null) {
          return const LoginScreen();
        }

        return BlocProvider(
          create: (context) => PairingScreenCubit(
            context.read<KidRepository>(),
            context.read<PairingService>(),
          ),
          child: const PairingScreen(),
        );

      },
    );
  }
}
