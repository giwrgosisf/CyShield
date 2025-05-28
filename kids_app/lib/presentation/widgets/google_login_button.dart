import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';
import '../../../core/app_theme.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoogleLoginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('login_google_button'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: AppTheme.secondary, width: 2),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shape: const StadiumBorder(),
        minimumSize: Size(double.infinity, 48),
      ),
      icon: Image.asset('assets/google_logo.png', height: 24),
      label: Text('Σύνδεση μέσω Google', style: TextStyle(color: Colors.black)),
      onPressed: onPressed,
    );
  }
}
