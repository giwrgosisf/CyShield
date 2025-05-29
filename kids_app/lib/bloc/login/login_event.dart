import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmailChanged extends LoginEvent {
  final String email;
  EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends LoginEvent {
  final String password;
  PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class LoginWithEmailPressed extends LoginEvent {}

class LoginWithGooglePressed extends LoginEvent {}

class PhoneNumberChanged extends LoginEvent {
  final String phoneNumber;
  PhoneNumberChanged(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneNumberSubmitted extends LoginEvent {
  final String phoneNumber;
  PhoneNumberSubmitted(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}