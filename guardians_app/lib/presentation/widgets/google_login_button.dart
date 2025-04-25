import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      key: const Key('login_google_button'),
      icon: Image.asset('assets/google_logo.png', height: 24),
      label: Text('Σύνδεση μέσω Google',style:TextStyle(color:Colors.black)),
      onPressed: () => context.read<LoginBloc>().add(LoginWithGooglePressed()),
      style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
    );
  }
}
