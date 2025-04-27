import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/register/register_bloc.dart';
import '../../../bloc/register/register_event.dart';
import '../../../bloc/register/register_state.dart';

class SurnameInput extends StatelessWidget {
  const SurnameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (p, c) => p.surname != c.surname,
      builder: (ctx, state) {
        return TextField(
          key: const Key('register_surname_input'),
          cursorColor: Colors.black,
          onChanged: (surname) => ctx.read<RegisterBloc>().add(SurnameChanged(surname)),
          decoration: InputDecoration(
            labelText: 'Επίθετο',
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
