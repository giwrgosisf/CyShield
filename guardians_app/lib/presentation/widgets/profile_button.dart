import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? color;

  const ProfileButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          elevation: 4,
          backgroundColor: color ?? AppTheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
