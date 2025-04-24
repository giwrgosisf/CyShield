import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../data/repositories/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authModel;

  LoginBloc(this._authModel) : super(const LoginState()) {
    on<EmailChanged>((e, emit) {
      emit(state.copyWith(email: e.email, errorMessage: null));
    });
    on<PasswordChanged>((e, emit) {
      emit(state.copyWith(password: e.password, errorMessage: null));
    });
    on<LoginWithEmailPressed>(_onEmailLogin);
    on<LoginWithGooglePressed>(_onGoogleLogin);
  }

  Future<void> _onEmailLogin(
    LoginWithEmailPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      final user = await _authModel.logInWithEmail(
        email: state.email,
        password: state.password,
      );
      if (user != null) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Log in with email failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onGoogleLogin(
    LoginWithGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    try {
      final user = await _authModel.signInWithGoogle();
      if (user != null) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Google sign in failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
