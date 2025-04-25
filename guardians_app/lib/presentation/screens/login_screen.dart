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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(context.read<AuthRepository>()),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/cyshield_logo.png',
                      height: 250,
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // Email
                    EmailInput(),
                    const SizedBox(height: 16),

                    // Password
                    PasswordInput(),
                    const SizedBox(height: 24),

                    // Sign in button
                    LoginButton(),
                    const SizedBox(height: 12),

                    // First time signup
                    TextButton(
                      onPressed: () {
                        // navigate to register
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Πρώτη φορά εδώ; ', style: TextStyle(color: Colors.black54)),
                          Text('Εγγράψου εδώ.', style: TextStyle(color: AppTheme.secondary)),
                        ],
                      ),
                    ),


                    const SizedBox(height: 16),

                    // Google
                    GoogleLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
