import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/bloc/profile/profile_cubit.dart';
import 'package:guardians_app/bloc/profile/profile_state.dart';

import '../../core/app_theme.dart';

class confirmDelete extends StatelessWidget {
  const confirmDelete({super.key});

  @override
  Widget build(BuildContext context) {
    // return AlertDialog(
    //   title: const Text('Διαγραφή προφίλ'),
    //   content: const Text('Θα διαγραφούν μόνιμα τα δεδομένα σας. Συνέχεια;'),
    //   actions: [
    //     TextButton(
    //       onPressed: (){if (context.mounted) Navigator.of(context).pop();},
    //       child: const Text('Άκυρο', style: TextStyle(color: Colors.black)),
    //     ),
    //     ElevatedButton(
    //       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    //       onPressed: () async{
    //         await context.read<ProfileCubit>().deleteProfile();
    //         if (context.mounted) Navigator.of(context).pop();
    //       },
    //       child: const Text('Διαγραφή',style: TextStyle(color: Colors.white)),
    //     ),
    //   ],
    // );

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (ctx, state) {
        if (state.status == ProfileStatus.deleted) {
          Navigator.of(ctx).pop();
        }

        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (ctx, state) {
        return AlertDialog(
          title: const Text('Διαγραφή προφίλ'),
          content:
              state.status == ProfileStatus.loading
                  ? const SizedBox(
                    height: 64,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                  : const Text(
                    'Θα διαγραφούν μόνιμα τα δεδομένα σας. Συνέχεια;',
                  ),
          actions:
              state.status == ProfileStatus.loading
                  ? null
                  : [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Άκυρο',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        context.read<ProfileCubit>().deleteProfile();
                        //if (context.mounted) Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Διαγραφή',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
        );
      },
    );
  }
}
