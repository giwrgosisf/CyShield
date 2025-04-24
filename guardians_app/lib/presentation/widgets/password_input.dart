import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';
import '../../../bloc/login/login_state.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) => p.password != c.password,
      builder: (ctx, state) {
        return TextField(
          key: const Key('login_password_input'),
          onChanged: (pwd) => ctx.read<LoginBloc>().add(PasswordChanged(pwd)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Συμπληρώσε εδώ',
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
