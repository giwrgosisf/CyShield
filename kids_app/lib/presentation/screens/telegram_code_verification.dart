import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/core/app_theme.dart';

import '../../bloc/telegram/telegam_code_cubit.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/telegram_code_form.dart';
import '../widgets/telegram_code_instructions.dart';
import '../widgets/network_icon.dart';

class TelegramCodeVerificationScreen extends StatelessWidget {
  final Map<String, dynamic>? arguments;



  const TelegramCodeVerificationScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final finalArguments = arguments ?? routeArguments;

    return Scaffold(
      appBar: const CustomAppBar(title: 'CyShield kids'),
      body: Builder(
        builder: (BuildContext innerContext) {
          if (finalArguments == null) {
            if (kDebugMode) {
              print('Arguments are null!');
            }
            return const Center(
              child: Text(
                'Error: Missing required parameters. Please go back and try again.',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final Map<String, dynamic> args = finalArguments;

          // Validate required fields
          final requiredFields = [
            'phone_number',
            'api_id',
            'api_hash',
            'phone_code_hash',
          ];
          for (String field in requiredFields) {
            if (!args.containsKey(field) || args[field] == null) {
              return Center(
                child: Text(
                  'Error: Missing required field: $field. Please go back and try again.',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }

          return BlocProvider(
            create:
                (context) => TelegramCodeCubit(
                  phoneNumber: args['phone_number']!,
                  apiId: args['api_id']!,
                  apiHash: args['api_hash']!,
                  phoneCodeHash: args['phone_code_hash']!,
                  onSuccess: () {
                    Navigator.pushNamed(
                      context,
                      '/allDone',
                    );
                  },
                  onPasswordRequired: () {
                    Navigator.pushNamed(
                      context,
                      '/telegram_password',
                      arguments: args,
                    );
                  },
                ),
            child: const TelegramCodeVerificationView(),
          );
        },
      ),
    );
  }
}

class TelegramCodeVerificationView extends StatelessWidget {
  const TelegramCodeVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IconLabelButton(
              assetPath: 'assets/icons/telegramicon.png',
              label: 'Telegram',
              backgroundColor: AppTheme.secondary,
              iconDiameter: 90,
            ),
            const SizedBox(height: 20),
            const TelegramCodeInstructionsCard(),
            const SizedBox(height: 20),
            const TelegramCodeForm(),
          ],
        ),
      ),
    );
  }
}
