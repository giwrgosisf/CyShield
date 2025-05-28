import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authModel;

  RegisterBloc(this._authModel) : super(const RegisterState()) {
    on<NameChanged>((e, emit) {
      emit(state.copyWith(name: e.name));
    });
    on<SurnameChanged>((e, emit) {
      emit(state.copyWith(surname: e.surname));
    });
    on<BirthDateChanged>((e, emit) {
      emit(state.copyWith(birthDate: e.birthDate));
    });
    on<EmailRegisterChanged>((e, emit) {
      emit(state.copyWith(email: e.email, errorMessage: null));
    });
    on<PasswordRegisterChanged>((e, emit) {
      emit(state.copyWith(password: e.password, errorMessage: null, status: RegisterStatus.initial));
    });
    on<ConfirmPasswordChanged>((e, emit) {
      emit(state.copyWith(confirmPassword: e.confirmPassword));
    });
    on<RegisterWithEmailPressed>(_registerWithEmailPressed);
  }




  Future<void> _registerWithEmailPressed(
      RegisterWithEmailPressed event,
      Emitter<RegisterState> emit,
      ) async {
    if (state.password != state.confirmPassword) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Passwords do not match',
        ),
      );
      return;
    }
    if (!state.isValid) return;
    emit(state.copyWith(status: RegisterStatus.submitting));
    try {
      final user = await _authModel.signUpWithEmail(
        name: state.name,
        surname: state.surname,
        email: state.email,
        password: state.password,
        birthDate: state.birthDate!,
        phoneNumber: state.phoneNumber
      );
      if (user != null) {
        emit(state.copyWith(status: RegisterStatus.success));
      } else {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'Sign up Failed!',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
