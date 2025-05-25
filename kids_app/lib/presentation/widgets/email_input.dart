import 'package:flutter/material.dart';
import 'package:kids_app/core/app_theme.dart';


class EmailInput extends StatelessWidget {
  const EmailInput({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      key: const Key('login_email_input'),
      cursorColor: Colors.black,
      onChanged: onChanged,
      // controller: TextEditingController(text: value)
      //   ..selection = TextSelection.collapsed(offset: value.length),
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
  }
}
