import 'package:flutter/material.dart';

class PairingPendingDialog extends StatelessWidget {
  final String message;


  const PairingPendingDialog({
    super.key,
    required this.message,
  });

  static Future<void> show(
      BuildContext context, {
        required String message,

      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PairingPendingDialog(
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading indicator
          const CircularProgressIndicator(
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Waiting for Guardian to respond...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Cancel button

        ],
      ),
    );
  }
}