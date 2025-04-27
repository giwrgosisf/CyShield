import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import '../../../bloc/register/register_bloc.dart';
import '../../../bloc/register/register_event.dart';
import '../../../bloc/register/register_state.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listenWhen:
          (prev, curr) =>
      prev.status != curr.status &&
          curr.status != RegisterStatus.submitting,
      listener: (ctx, state) {
        if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error')),
          );
        } else if (state.status == RegisterStatus.success) {
          Navigator.of(ctx).pushReplacementNamed('/temp');
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
            state.status == RegisterStatus.submitting
                ? null    // disabled
                : () => ctx.read<RegisterBloc>().add(RegisterWithEmailPressed()),
            child:
            state.status == RegisterStatus.submitting
                ? SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.thirdBlue),
            )
                : Text('Εγγράψου', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}
