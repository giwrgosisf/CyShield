import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../bloc/family/family_cubit.dart';
import '../../bloc/family/family_state.dart';
import '../widgets/kid_card.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyCubit, FamilyState>(
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
        if (kids.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Δεν έχουν προστεθεί παιδιά ακόμα.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 2),
                    ],
                  ),
                  child: const Text(
                    'Οικογένεια',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kids.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final kid = kids[index];
                  return KidCard(
                    kid: kid,
                    primaryColor: AppTheme.primary,
                    onRemove:
                        () => context.read<FamilyCubit>().removeKid(kid.id),
                  );
                },
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.pushNamed(context, '/add_child_info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  child: const Text('Πρόσθεσε παιδί'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
