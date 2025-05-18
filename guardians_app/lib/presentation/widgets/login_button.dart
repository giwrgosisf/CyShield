import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/login/login_bloc.dart';
import '../../../bloc/login/login_event.dart';
import '../../../bloc/login/login_state.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen:
          (prev, curr) =>
              prev.status != curr.status &&
              curr.status != LoginStatus.submitting,
      listener: (ctx, state) {
        if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        }
        else if (state.status == LoginStatus.success) {
          // dispose the login page and go to /home
          Navigator.of(ctx).pushNamedAndRemoveUntil(
            '/home',
                (_) => false,
          );
        }
      },
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (ctx, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.thirdBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed:
                state.status == LoginStatus.submitting
                    ? null    // disabled
                    : () => ctx.read<LoginBloc>().add(LoginWithEmailPressed()),
            child:
                state.status == LoginStatus.submitting
                    ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                    )
                    : Text('Σύνδεσου', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}
