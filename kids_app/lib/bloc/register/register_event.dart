import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NameChanged extends RegisterEvent {
  final String name;
  NameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class SurnameChanged extends RegisterEvent {
  final String surname;
  SurnameChanged(this.surname);
  @override
  List<Object?> get props => [surname];
}

class EmailChanged extends RegisterEvent {
  final String email;
  EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends RegisterEvent {
  final String password;
  PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class ConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;
  ConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

class BirthDateChanged extends RegisterEvent {
  final DateTime birthDate;
  BirthDateChanged(this.birthDate);
  @override
  List<Object?> get props => [birthDate];
}

class EmailRegisterChanged extends RegisterEvent {
  final String email;
  EmailRegisterChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordRegisterChanged extends RegisterEvent {
  final String password;
  PasswordRegisterChanged(this.password);
  @override
  List<Object?> get props => [password];
}


class RegisterWithEmailPressed extends RegisterEvent {}
