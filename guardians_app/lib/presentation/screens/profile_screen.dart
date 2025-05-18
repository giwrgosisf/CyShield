import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../core/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/changeName_dialog.dart';

import '../widgets/custom_appbar.dart';
import '../widgets/profile_button.dart';

class ProfileScreen extends StatelessWidget {
  static const _navIndex = 3;

  static const _routes = ['/home', '/family', '/notifications', '/profile'];
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // return BlocBuilder<HomeCubit, HomeState>(
    //   builder: (context, homeState) {
    //     if (homeState.status != HomeStatus.success) {
    //       return const Center(
    //         child: CircularProgressIndicator(color: AppTheme.primary),
    //       );
    //     }
    //     final profile = homeState.profile!;
    //     return BlocProvider(
    //       create:
    //           (_) => ProfileCubit(
    //             context.read<AuthRepository>(),
    //             context.read<UserRepository>(),
    //           ),
    //       child: BlocListener<ProfileCubit, ProfileState>(
    //         listener: (ctx, state) {
    //           if (state.status == ProfileStatus.failure) {
    //             ScaffoldMessenger.of(ctx,).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    //           }
    //         },
    //         child: const _Body(),
    //       ),
    //     );
    //   },
    // );
    return BlocProvider(
      create:
          (_) => ProfileCubit(
            context.read<AuthRepository>(),
            context.read<UserRepository>(),
          ),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Cyshield'),
        body: const _Body(),
        bottomNavigationBar: BottomNav(
          current: _navIndex,
          onTap: (i) {
            final target = _routes[i];

            if (ModalRoute.of(context)!.settings.name != target) {
              Navigator.pushReplacementNamed(context, target);
            }
          },
        ),
      ),
    );
    // return Scaffold(
    //   appBar: const CustomAppBar(title: 'Cyshield'),
    //   body: SafeArea(
    //     child: BlocProvider(
    //       create: (_) {
    //         final cubit = ProfileCubit(
    //           context.read<AuthRepository>(),
    //           context.read<UserRepository>(),
    //         );
    //         return cubit;
    //       },
    //       child: const _Body(),
    //     ),
    //   ),
    //   bottomNavigationBar: BottomNav(
    //     current: _navIndex,
    //     onTap: (i) {
    //       final target = _routes[i];
    //       // only navigate if we’re not already on that route
    //       if (ModalRoute.of(context)!.settings.name != target) {
    //         Navigator.pushReplacementNamed(context, target);
    //       }
    //     },
    //   ),
    // );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen:
          (_, state) =>
              state.status == ProfileStatus.deleted ||
              (state.status == ProfileStatus.failure &&
                  state.errorMessage != 'wrong-password'),
      listener: (ctx, state) {
        if (state.status == ProfileStatus.deleted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Ο λογαριασμός σας διαγράφηκε με επιτυχία'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (_) => false);
        }
        if (state.status == ProfileStatus.failure &&
            state.errorMessage != null &&
            state.errorMessage != 'wrong-password') {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (ctx, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.updating) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // if (state.status == ProfileStatus.failure &&
          //     state.errorMessage != null &&
          //     state.errorMessage != 'wrong-password') {
          //   return const SizedBox.shrink();
          // }

          if (state.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final profile = state.profile!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 96,
                  backgroundImage:
                      profile.profilePhoto != null
                          ? NetworkImage(profile.profilePhoto!)
                          : const AssetImage('assets/images/profile_image.png')
                              as ImageProvider,
                ),

                const SizedBox(height: 12),

                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // buttons ------------------------------------------------
                ProfileButton(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return BlocProvider.value(
                            value: context.read<ProfileCubit>(),
                            child: ChangeNameDialog(
                              currentName: profile.firstName,
                            ),
                          );
                        },
                      ),
                  label: 'Αλλαγή Username',
                ),
                const SizedBox(height: 20),
                ProfileButton(label: 'Αλλαγή εικόνας προφίλ', onPressed: () {}),
                const SizedBox(height: 20),
                ProfileButton(
                  label: 'Διαγραφή προφιλ',
                  onPressed: () => _promptPasswordAndDelete(context),
                ),
                const SizedBox(height: 40),
                ProfileButton(
                  label: 'Αποσύνδεση',
                  color: Colors.red.shade700,
                  onPressed: () async {
                    await context.read<ProfileCubit>().logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (_) => false);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _promptPasswordAndDelete(BuildContext context) {
    final passwordController = TextEditingController();
    String? error;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dc) => StatefulBuilder(
            builder: (ctx, setState) {
              return BlocProvider.value(
                value: context.read<ProfileCubit>(),
                child: BlocListener<ProfileCubit, ProfileState>(
                  listener: (listenerContext, state) {
                    if (state.status == ProfileStatus.deleted) {
                      Navigator.of(dc).pop();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (_) => false);
                    } else if (state.status == ProfileStatus.failure &&
                        state.errorMessage == 'wrong-password') {
                      setState(() {
                        error = 'Λανθασμένος κωδικός';
                      });
                    }
                  },
                  child: AlertDialog(
                    title: const Text('Διαγραφή προφίλ'),
                    content: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (builderContext, state) {
                        if (state.status == ProfileStatus.updating) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Γίνεται διαγραφή του λογαριασμού σας...',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Παρακαλώ πληκτρολογήστε τον κωδικό σας για επιβεβαίωση',
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Κωδικός',
                                errorText: error,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    actions: [
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (ctx, state) {
                          final isLoading =
                              state.status == ProfileStatus.updating;
                          return TextButton(
                            onPressed:
                                isLoading ? null : () => Navigator.of(dc).pop(),
                            child: const Text('Άκυρο'),
                          );
                        },
                      ),
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (ctx, state) {
                          final isLoading =
                              state.status == ProfileStatus.updating;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isLoading ? Colors.grey : Colors.red,
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      final pw = passwordController.text.trim();
                                      if (pw.isEmpty) {
                                        setState(
                                          () =>
                                              error =
                                                  'Πρέπει να εισάγετε κωδικό',
                                        );
                                        return;
                                      }
                                      await ctx
                                          .read<ProfileCubit>()
                                          .deleteProfile(password: pw);
                                    },
                            child: const Text('Διαγραφή'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}
