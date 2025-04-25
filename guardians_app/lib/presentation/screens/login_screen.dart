import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/login/login_bloc.dart';
import '../../bloc/login/login_event.dart';
import '../../bloc/login/login_state.dart';
import '../../core/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/login_button.dart';
import '../widgets/google_login_button.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(context.read<AuthRepository>()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/cyshield_logo.png',
                    height: 300,
                    width: 300,
                  ),
                  const SizedBox(height: 12),
                  // Email/password form card
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.lightGray),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          EmailInput(),
                          const SizedBox(height: 16),
                          PasswordInput(),
                          const SizedBox(height: 24),
                          LoginButton(),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pushNamed('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Πρώτη φορά εδώ; ', style: TextStyle(color: Colors.black54)),
                                Text('Εγγράψου εδώ.', style: TextStyle(color: AppTheme.primary)),
                              ],
                            ),

                          ),
                        ],
                      ),
                    ),
                  ),

                  // Separator line
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 24),

                  // Google login button below
                  GoogleLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
