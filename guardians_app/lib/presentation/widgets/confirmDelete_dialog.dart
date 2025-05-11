import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/bloc/profile/profile_cubit.dart';

import '../../bloc/home/home_cubit.dart';

class confirmDelete extends StatelessWidget {
  const confirmDelete({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Διαγραφή προφίλ'),
      content: const Text('Θα διαγραφούν μόνιμα τα δεδομένα σας. Συνέχεια;'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(context),
          child: const Text('Άκυρο', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async{
            await context.read<HomeCubit>().close();
            context.read<ProfileCubit>().deleteProfile();
            Navigator.of(context).pop(context);
          },
          child: const Text('Διαγραφή',style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
