import 'package:flutter/material.dart';
import 'package:kids_app/core/app_theme.dart';

class TelegramCodeInstructionsCard extends StatelessWidget {
  const TelegramCodeInstructionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Οδηγίες Επιβεβαίωσης',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildInstructionStep(
              context,
              '1',
              'Ελέγξτε τα μηνύματά σας στο Telegram',
              'Θα λάβετε έναν κωδικό επιβεβαίωσης από το Telegram',
            ),

            const SizedBox(height: 8),

            _buildInstructionStep(
              context,
              '2',
              'Εισάγετε τον κωδικό',
              'Ο κωδικός αποτελείται από 5-6 ψηφία',
            ),

            const SizedBox(height: 8),

            _buildInstructionStep(
              context,
              '3',
              'Πατήστε Επιβεβαίωση',
              'Αν ο κωδικός είναι σωστός, θα μεταβείτε στην επόμενη σελίδα',
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Αν δεν λαμβάνετε κωδικό, πατήστε "Αποστολή νέου κωδικού"',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context,
      String stepNumber,
      String title,
      String description,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],

                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}