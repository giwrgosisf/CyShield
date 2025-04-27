import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/bloc/register/register_event.dart';
import '../../bloc/register/register_bloc.dart';
import '../../bloc/register/register_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/app_theme.dart';
import '../widgets/email_input.dart';
import '../widgets/password_input.dart';
import '../widgets/register_button.dart';
import '../widgets/name_input.dart';
import '../widgets/surname_input.dart';
import '../widgets/confirmPassword_input.dart';
import '../widgets/birthdate_input.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(context.read<AuthRepository>()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
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
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          NameInput(),
                          const SizedBox(height: 16),
                          SurnameInput(),
                          const SizedBox(height: 16),
                          BirthDateInput(),
                          const SizedBox(height: 16),
                          BlocBuilder<RegisterBloc, RegisterState>(
                            buildWhen: (p, c) => p.email != c.email,
                            builder:
                                (context, state) => EmailInput(
                                  value: state.email,
                                  onChanged:
                                      (v) => context.read<RegisterBloc>().add(
                                        EmailRegisterChanged(v),
                                      ),
                                ),
                          ),

                          const SizedBox(height: 16),
                          BlocBuilder<RegisterBloc, RegisterState>(
                            buildWhen: (p, c) => p.password != c.password,
                            builder:
                                (context, state) => PasswordInput(
                                  onChanged:
                                      (v) => context.read<RegisterBloc>().add(
                                        PasswordRegisterChanged(v),
                                      ),
                                ),
                          ),
                          const SizedBox(height: 24),
                          ConfirmPasswordInput(),
                          const SizedBox(height: 24),
                          RegisterButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
