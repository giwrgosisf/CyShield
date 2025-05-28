import 'package:flutter/foundation.dart';
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
    on<PhoneNumberChanged>((e, emit) {
      emit(state.copyWith(phoneNumber: e.phoneNumber));
    });
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
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
    if (kDebugMode) print("LoginBloc: _onGoogleLogin - Initial state: ${state.status}");
    emit(state.copyWith(status: LoginStatus.submitting)); // Set to submitting
    if (kDebugMode) print("LoginBloc: _onGoogleLogin - Emitting submitting");

    try {
      final user = await _authModel.signInWithGoogle();
      if (kDebugMode) print("LoginBloc: _onGoogleLogin - Google sign-in result: ${user != null ? 'User present' : 'No user'}");

      if (user != null) {
        final phone = await _authModel.getPhoneNumber(user.uid);
        if (kDebugMode) {
          print("LoginBloc: _onGoogleLogin - Phone returned: '$phone'");
          print("LoginBloc: _onGoogleLogin - Phone is null: ${phone == null}");
          print("LoginBloc: _onGoogleLogin - Phone is empty: ${phone?.isEmpty}");
          print("LoginBloc: _onGoogleLogin - Should require phone: ${phone == null || (phone?.isEmpty ?? true)}");
        }

        if (phone == null || phone.isEmpty) {
          if (kDebugMode) print("LoginBloc: _onGoogleLogin - Emitting requiresPhoneNumber");
          emit(state.copyWith(
            status: LoginStatus.requiresPhoneNumber,
            phoneNumber: '', // Reset phone number in state
          ));
        } else {
          // If phone exists, set status to success
          if (kDebugMode) print("LoginBloc: _onGoogleLogin - Emitting success (phone exists)");
          emit(state.copyWith(
            status: LoginStatus.success,
            phoneNumber: phone,
          ));
        }
      } else {
        if (kDebugMode) print("LoginBloc: _onGoogleLogin - Emitting failure (Google sign in failed)");
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Google sign in failed',
        ));
      }
    } catch (e) {
      if (kDebugMode) print("LoginBloc: _onGoogleLogin - Catching error: $e");
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPhoneNumberSubmitted(
      PhoneNumberSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - Initial state: ${state.status}");
    final currentUser = _authModel.currentUser;
    if (currentUser == null) {
      if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - User not authenticated, emitting failure");
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'User not authenticated',
      ));
      return;
    }


    if (state.phoneNumber.trim().isEmpty) {
      if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - Phone number empty, emitting failure");
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Phone number is required',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.submitting));
    if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - Emitting submitting for phone save");
    try {
      await _authModel.savePhoneNumber(currentUser.uid, state.phoneNumber);
      if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - Phone saved, emitting success");
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      if (kDebugMode) print("LoginBloc: _onPhoneNumberSubmitted - Error saving phone: $e, emitting failure");
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}