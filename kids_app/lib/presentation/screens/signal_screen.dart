import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/presentation/widgets/custom_appbar.dart';
import 'package:kids_app/presentation/widgets/network_icon.dart';
import 'package:kids_app/presentation/widgets/instructions_card.dart';

import '../../bloc/signal/signal_cubit.dart';
import '../../bloc/signal/signal_state.dart';
import '../../core/app_theme.dart';
 // Adjust path as needed

class SignalScreen extends StatelessWidget {
  const SignalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignalCubit(),
      child: Scaffold(
        appBar: const CustomAppBar(title: "CyShield kids"),
        body: BlocConsumer<SignalCubit, SignalState>(
          listener: (context, state) {
            if (state is SignalSuccess) {
              Navigator.pushReplacementNamed(
                context,
                '/allDone',
              );
            } else if (state is SignalFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<SignalCubit>();
            final isLoading = state is SignalLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  IconLabelButton(
                    assetPath: 'assets/icons/signal.png',
                    label: 'Signal Messenger',
                    backgroundColor: Colors.transparent,
                    iconDiameter: 90,
                  ),
                  const SizedBox(height: 50),
                  InstructionsCard(
                    instructions: [
                      InstructionItem(
                        text: 'Για να συνδεθείτε με τον λογαριασμό Signal:',
                      ),
                      InstructionItem(
                        text: '1. Από μια άλλη συσκευή μεταβείτε στη διεύθυνση:',
                      ),
                      InstructionItem(
                        text: 'https://signal.cyshield.org/link',
                      ),
                      InstructionItem(
                        text: '2. Θα εμφανιστεί ένας κωδικός QR',
                      ),
                      InstructionItem(
                        text:
                        '3. Σκανάρετε τον κωδικό QR με την εφαρμογή Signal από το κινητό του παιδιού',
                        spacingAfter: 12.0,
                      ),
                      InstructionItem(
                        text: '4. Ο λογαριασμός του παιδιού σας συνδέθηκε!',
                      ),
                      InstructionItem(
                        text:
                        'Πατήστε επιβεβαίωση μόνο όταν ολοκληρώσετε όλα τα βήματα παραπάνω!',
                      ),
                    ],
                  ),
                  const SizedBox(height: 90),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: isLoading ? null : () => cubit.confirmConnection(),
                    child: isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Επιβεβαίωση',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
