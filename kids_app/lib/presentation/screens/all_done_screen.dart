
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/core/app_theme.dart';
import '../../bloc/all_done/all_done_cubit.dart';
import '../../bloc/all_done/all_done_state.dart';
import '../widgets/custom_appbar.dart';


class AllDoneScreen extends StatelessWidget {
  const AllDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AllDoneCubit()
        ..setSignal()
        ..setTelegram(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(title: 'CyShield kids'),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Success Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: const Text(
                    'Όλα έτοιμα!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Moderation Status Cards
                BlocBuilder<AllDoneCubit, AllDoneState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _buildModerationCard(
                          title: 'Signal Moderation:',
                          status: state.signalActive ? 'Active' : 'Inactive',
                          isActive: state.signalActive,
                          onRefresh: () => context.read<AllDoneCubit>().setSignal(),
                        ),
                        const SizedBox(height: 20),
                        _buildModerationCard(
                          title: 'Telegram Moderation:',
                          status: state.telegramActive ? 'Active' : 'Inactive',
                          isActive: state.telegramActive,
                          onRefresh: () => context.read<AllDoneCubit>().setTelegram(),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 60),
                const SizedBox(height: 250),
                // Action Button
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/pairing');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Επιστροφή στην αρχική',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModerationCard({
    required String title,
    required String status,
    required bool isActive,
    required VoidCallback onRefresh,
  }) {
    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondary : Colors.grey[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.secondary : Colors.grey[400]!)
                  .withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[400] : Colors.red[400],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? Colors.green[400]! : Colors.red[400]!)
                            .withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
