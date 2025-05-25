import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PairingSuccessDialog extends StatelessWidget {
  final String? message;
  final VoidCallback? onContinue;

  const PairingSuccessDialog({
    super.key,
    this.message,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 48,
      ),
      title: const Text(
        'Επιτυχής Σύνδεση!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      content: Text(
        message ?? 'Συνδεθήκατε επιτυχώς με τον κηδεμόνα σας!',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Συνέχεια',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> show(
      BuildContext context, {
        String? message,
        VoidCallback? onContinue,
      }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PairingSuccessDialog(
        message: message,
        onContinue: onContinue,
      ),
    );
  }
}