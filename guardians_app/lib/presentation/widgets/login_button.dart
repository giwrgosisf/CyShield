import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        } else if (state.status == LoginStatus.success) {
          Navigator.of(ctx).pushReplacementNamed('/temp');
        }
      },
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (ctx, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                state.status == LoginStatus.submitting
                    ? null    // disabled
                    : () => ctx.read<LoginBloc>().add(LoginWithEmailPressed()),
            child:
                state.status == LoginStatus.submitting
                    ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),     // spinner loading
                    )
                    : Text('Σύνδεσου'),
          ),
        );
      },
    );
  }
}
