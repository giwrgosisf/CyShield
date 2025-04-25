import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';


class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return OutlinedButton.icon(
      key: const Key('login_google_button'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: BorderSide(color: Color(0xFF5FA6F9)),
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shape: const StadiumBorder(),
        minimumSize: Size(double.infinity, 48),
      ),
      icon: Image.asset('assets/google_logo.png', height: 24),
      label: Text('Σύνδεση μέσω Google',style:TextStyle(color:Colors.black)),
      onPressed: () => context.read<LoginBloc>().add(LoginWithGooglePressed()),
    );
  }
}
