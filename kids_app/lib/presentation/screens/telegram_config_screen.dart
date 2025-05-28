import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/telegram/telegram_config_cubit.dart';
import 'package:kids_app/bloc/telegram/telegram_config_state.dart';

import '../../core/app_theme.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/instructions_card.dart';
import '../widgets/telegram_config_form.dart';
import '../widgets/network_icon.dart';

class TelegramConfigScreen extends StatelessWidget {
  const TelegramConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => TelegramConfigCubit(
            onCodeSent: (data) {
              // Navigate to code verification screen
              if (kDebugMode) {
                print('=== Data to transfer ===');
                print(data);
              }
              Navigator.pushNamed(
                context,
                '/telegram_code_verification',
                arguments: data,
              );
            },
            onAlreadyAuthorized: () {
              // Navigate to main screen or show success
              Navigator.pushReplacementNamed(
                context,
                '/allDone',
                arguments: {'signalActive': false, 'telegramActive': true},
              );
            },
          ),
      child: const TelegramConfigView(),
    );
  }
}

class TelegramConfigView extends StatelessWidget {
  const TelegramConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'CyShield kids'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IconLabelButton(
              assetPath: 'assets/icons/telegramicon.png',
              label: 'Telegram',
              backgroundColor: AppTheme.secondary,
            ),
            const SizedBox(height: 20),
            InstructionsCard(
              instructions: [
                InstructionItem(
                  text: '1. Συνδεθείτε στο Telegram: https://my.telegram.org/',
                ),
                InstructionItem(
                  text: '2 Λάβετε κωδικό επιβεβαίωσης στο telegram.',
                ),
                InstructionItem(
                  text:
                      '3. Μεταβείτε στην ενότητα "API development tools" και συμπληρώστε τη φόρμα.',
                ),
                InstructionItem(
                  text:
                      'Συνίσταται να καταχωρίσετε ονόματα χωρίς ειδικούς χαρακτήρες',
                ),
                InstructionItem(
                  text:
                      'Παράδειγμα: App Title: TelegramTracker\n Short Name: teletracker',
                  isBold: false,
                  spacingAfter: 12.0,
                ),
                InstructionItem(
                  text: 'Tο url αφήστε το κενό.\nDevelopment platform: Android',
                ),
                InstructionItem(
                  text:
                      'Θα λάβετε τις παραμέτρους api_id και api_hash που απαιτούνται για την εξουσιοδότηση του χρήστη',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const TelegramConfigForm(),
          ],
        ),
      ),
    );
  }
}
