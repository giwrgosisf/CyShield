import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/bloc/profile/profile_cubit.dart';

class ChangeNameDialog extends StatelessWidget {
  final String currentName;
  const ChangeNameDialog({super.key, required this.currentName});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: currentName);
    return AlertDialog(
      title: const Text('Νέο Username'),
      content: TextField(controller: controller,decoration: const InputDecoration(hintText: 'π.χ. Δημήτρης')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Άκυρο'),
        ),
        ElevatedButton(
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty) {
              context.read<ProfileCubit>().updateName(newName);
              Navigator.pop(context);
            }
          },
          child: const Text('Αποθήκευση'),
        ),
      ],
    );
  }
}
