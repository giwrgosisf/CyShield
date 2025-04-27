import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/register/register_bloc.dart';
import '../../../bloc/register/register_event.dart';
import '../../../bloc/register/register_state.dart';
import 'package:intl/intl.dart'; // add to pubspec: intl: ^0.17.0

class BirthDateInput extends StatelessWidget {
  const BirthDateInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (p, c) => p.birthDate != c.birthDate,
      builder: (ctx, state) {
        final text =
            state.birthDate == null
                ? 'Επίλεξε ημερομηνία γέννησης'
                : DateFormat.yMd().format(state.birthDate!);
        return TextField(
          readOnly: true,
          onTap: () async {
            final registerBloc = context.read<RegisterBloc>();
            final picker = await showDatePicker(
              context: context,
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                    data: Theme.of(context).copyWith(  // override MaterialApp ThemeData
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primary,  //header and selected day background color
                    onPrimary: Colors.white, // titles and
                    onSurface: Colors.black, // Month days , years
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.thirdBlue, // ok , cancel    buttons
                    ),
                  ),
                ), child: child!);
              },
            );
            if (picker != null) {
              registerBloc.add(BirthDateChanged(picker));

            }
          },
          decoration: InputDecoration(
            labelText: 'Ημερομηνία Γέννησης',
            hintText: text,
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
