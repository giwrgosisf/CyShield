import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class PairingFailureDialog extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const PairingFailureDialog({
    super.key,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.error,
        color: Colors.red,
        size: 48,
      ),
      title: const Text(
        'Αποτυχία Σύνδεσης',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage ?? 'Η σύνδεση με τον κηδεμόνα απέτυχε.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            'Παρακαλώ ελέγξτε το ID του κηδεμόνα και δοκιμάστε ξανά.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Ακύρωση',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Δοκιμή Ξανά',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> show(
      BuildContext context, {
        String? errorMessage,
        VoidCallback? onCancel,
        VoidCallback? onRetry,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PairingFailureDialog(
        errorMessage: errorMessage,
        onCancel: onCancel,
        onRetry: onRetry,
      ),
    );
  }
}
