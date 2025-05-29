import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import 'package:guardians_app/presentation/widgets/bottom_navbar.dart';
import '../../bloc/family/family_cubit.dart';
import '../../bloc/family/family_state.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/kid_card.dart';

class FamilyScreen extends StatelessWidget {
  static const _navIndex = 1;

  static const _routes = ['/home', '/family', '/notifications', '/profile'];

  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cyshield'),
      body: SafeArea(
        child: BlocConsumer<FamilyCubit, FamilyState>(
          listener: (ctx, state) {
            if (state.status == FamilyStatus.failure) {
              ScaffoldMessenger.of(
                ctx,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (ctx, state) {
            if (state.status == FamilyStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final kids = state.kids;
            // if (kids.isEmpty) {
            //   return Center(
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 24),
            //       child: Text(
            //         'Δεν έχουν προστεθεί παιδιά ακόμα.',
            //         style: TextStyle(fontSize: 18),
            //         textAlign: TextAlign.center,
            //       ),
            //     ),
            //   );
            // }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Οικογένεια',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (kids.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 48,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.family_restroom,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Δεν έχουν προστεθεί παιδιά ακόμα.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: kids.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (context, index) {
                        final kid = kids[index];
                        return KidCard(
                          kid: kid,
                          primaryColor: AppTheme.primary,
                          onRemove:
                              () =>
                                  context.read<FamilyCubit>().removeKid(kid.id),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/add_child_info'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Πρόσθεσε παιδί',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: _navIndex,
        onTap: (i) {
          final target = _routes[i];
          // only navigate if we’re not already on that route
          if (ModalRoute.of(context)!.settings.name != target) {
            Navigator.pushReplacementNamed(context, target);
          }
        },
      ),
    );
  }
}
