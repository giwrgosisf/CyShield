import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/register/register_bloc.dart';
import '../../../bloc/register/register_event.dart';
import '../../../bloc/register/register_state.dart';

class ConfirmPasswordInput extends StatelessWidget {
  const ConfirmPasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (p, c) => p.confirmPassword != c.confirmPassword,
      builder: (ctx, state) {
        return TextField(
          key: const Key('login_password_input'),
          cursorColor: Colors.black,
          onChanged: (confirmPassword) => ctx.read<RegisterBloc>().add(ConfirmPasswordChanged(confirmPassword)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Συμπλήρωσε εδώ',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
        );
      },
    );
  }
}
