import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/home/home_cubit.dart';
import '../../bloc/home/home_state.dart';
import '../../bloc/profile/profile_cubit.dart';
import '../../bloc/profile/profile_state.dart';
import '../../core/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/changeName_dialog.dart';
import '../widgets/confirmDelete_dialog.dart';
import '../widgets/profile_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        if (homeState.status != HomeStatus.success) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        final profile = homeState.profile!;
        return BlocProvider(
          create:
              (_) => ProfileCubit(
                context.read<AuthRepository>(),
                context.read<UserRepository>(),
              ),
          child: BlocListener<ProfileCubit, ProfileState>(
            listener: (ctx, state) {
              if (state.status == ProfileStatus.failure) {
                ScaffoldMessenger.of(ctx,).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              }
            },
            child: const _Body(),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (ctx, state) {
            if (state.status == ProfileStatus.deleted) {
              return const SizedBox.shrink();
            }
            if (state.status == ProfileStatus.loading ||
                state.status == ProfileStatus.updating) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state.status == ProfileStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ??
                      'Σφάλμα κατά την φόρτωση της σελίδας. Παρακαλώ προσπαθήστε ξανά αργότερα.',
                ),
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
                            : const AssetImage(
                                  'assets/images/profile_image.png',
                                )
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
                  ProfileButton(
                    label: 'Αλλαγή εικόνας προφίλ',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  ProfileButton(
                    label: 'Διαγραφή προφιλ',
                    onPressed:
                        () => showDialog(
                          context: context,
                          builder:
                              (dialogCtx) => BlocProvider.value(value: context.read<ProfileCubit>(),
                              child: confirmDelete())
                        ),
                  ),
                  const SizedBox(height: 40),
                  ProfileButton(
                    label: 'Αποσύνδεση',
                    color: Colors.red.shade700,
                    onPressed:
                        () => context.read<ProfileCubit>().logout(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
