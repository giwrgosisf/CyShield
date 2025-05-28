import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/login/login_bloc.dart';
import '../../core/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/login_button.dart';
import '../widgets/google_login_button.dart';
import '../../../bloc/login/login_event.dart';
import '../../../bloc/login/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(context.read<AuthRepository>()),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (kDebugMode) {
            print("LoginScreen Listener: Received state: ${state.status}");
            if (state.errorMessage != null) {
              print("LoginScreen Listener: Error: ${state.errorMessage}");
            }
          }
          if (state.status == LoginStatus.requiresPhoneNumber) {
            if (kDebugMode) {
              print("LoginScreen Listener: Action: Showing phone dialog");
            }
            _showPhoneNumberDialog(context);
          } else if (state.status == LoginStatus.success) {
            if (kDebugMode) {
              print("LoginScreen Listener: Action: Navigating to /pairing");
            }
            // Navigate to pairing screen on success
            Navigator.pushReplacementNamed(context, '/pairing');
          } else if (state.status == LoginStatus.failure) {
            if (kDebugMode) {
              print("LoginScreen Listener: Action: Showing SnackBar");
            }
            // Show error message
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
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
                            BlocBuilder<LoginBloc, LoginState>(
                              buildWhen: (p, c) => p.email != c.email,
                              builder: (context, state) => EmailInput(
                                value: state.email,
                                onChanged: (v) => context.read<LoginBloc>().add(
                                  EmailChanged(v),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<LoginBloc, LoginState>(
                              buildWhen: (p, c) => p.password != c.password,
                              builder: (context, state) => PasswordInput(
                                onChanged: (v) => context.read<LoginBloc>().add(
                                  PasswordChanged(v),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            LoginButton(),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).pushNamed('/register'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Πρώτη φορά εδώ;',
                                      style: TextStyle(color: Colors.black54),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: TextButton(
                                      onPressed: () => Navigator.of(context).pushNamed('/register'),
                                      child: const Text(
                                        'Εγγράψου εδώ.',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
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
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return GoogleLoginButton(
                          onPressed: state.status == LoginStatus.submitting
                              ? null
                              : () => context.read<LoginBloc>().add(LoginWithGooglePressed()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    if (kDebugMode) print("LoginScreen: Attempting to show phone number dialog...");
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LoginBloc>(), // Share the same bloc instance
        child: Builder( // Added Builder here to get a fresh context for internal logging
            builder: (innerBuilderContext) {
              if (kDebugMode) print("Phone Dialog: Building content for dialog.");
              return BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (kDebugMode) {
                    print("Phone Dialog Listener: Received state: ${state.status}");
                    if (state.errorMessage != null) {
                      print("Phone Dialog Listener: Error: ${state.errorMessage}");
                    }
                  }
                  if (state.status == LoginStatus.success) {
                    if (kDebugMode) {
                      print("Phone Dialog Listener: Action: Pop dialog, Navigate to /pairing");
                    }
                    Navigator.of(dialogContext).pop(); // Close dialog first
                    Navigator.pushReplacementNamed(context, '/pairing');
                  } else if (state.status == LoginStatus.failure) {
                    if (kDebugMode) {
                      print("Phone Dialog Listener: Action: Pop dialog (failure)");
                    }
                    Navigator.of(dialogContext).pop(); // Close dialog
                    // Error will be handled by the main BlocListener outside this dialog
                  }
                },
                child: BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (p, c) => p.status != c.status || p.phoneNumber != c.phoneNumber, // Only rebuild on status or phone number change
                  builder: (context, state) {
                    return AlertDialog(
                      title: const Text('Enter Phone Number'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            onChanged: (value) => context.read<LoginBloc>().add(
                              PhoneNumberChanged(value),
                            ),
                            decoration: const InputDecoration(
                              hintText: '+1234567890',
                              labelText: 'Phone Number',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          if (state.status == LoginStatus.submitting)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: state.status == LoginStatus.submitting
                              ? null
                              : () {
                            if (kDebugMode) print("Phone Dialog: Cancel button pressed.");
                            Navigator.of(dialogContext).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: state.status == LoginStatus.submitting
                              ? null
                              : () {
                            if (kDebugMode) print("Phone Dialog: Submit button pressed.");
                            context.read<LoginBloc>().add(PhoneNumberSubmitted());
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
        ),
      ),
    );
  }
}