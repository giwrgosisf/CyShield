import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('login_password_input'),
      onChanged: onChanged,
      cursorColor: Colors.black,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
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
  }
}
