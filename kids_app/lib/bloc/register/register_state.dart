import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, submitting, success, failure }

class RegisterState extends Equatable {
  final String name;
  final String surname;
  final DateTime? birthDate;
  final String email;
  final String password;
  final String confirmPassword;
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    this.name = '',
    this.surname = '',
    this.birthDate,
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  bool get isValid =>
      name.isNotEmpty &&
          surname.isNotEmpty &&
          birthDate != null &&
          email.contains('@') &&
          password.length >= 6 &&
          password == confirmPassword;

  RegisterState copyWith({
    String? name,
    String? surname,
    DateTime? birthDate,
    String? email,
    String? password,
    String? confirmPassword,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    name,
    surname,
    birthDate,
    email,
    password,
    confirmPassword,
    status,
    errorMessage,
  ];
}
