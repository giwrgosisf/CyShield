import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';
import '../../../bloc/login/login_state.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) => p.email != c.email,
      builder: (ctx, state) {
        return TextField(
          key: const Key('login_email_input'),
          cursorColor: Colors.black,
          onChanged: (email) => ctx.read<LoginBloc>().add(EmailChanged(email)),
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Συμπλήρωσε εδώ',
            // border: OutlineInputBorder(),
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
