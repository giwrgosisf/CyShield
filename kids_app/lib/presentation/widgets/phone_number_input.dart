
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class PhoneNumberInput extends StatelessWidget {
  const PhoneNumberInput({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.phone,
      key: const Key('phone_number_input'),
      cursorColor: Colors.black,
      onChanged: onChanged,
      // controller: TextEditingController(text: value)
      //   ..selection = TextSelection.collapsed(offset: value.length),
      decoration: InputDecoration(
        labelText: 'Τηλέφωνο',
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
