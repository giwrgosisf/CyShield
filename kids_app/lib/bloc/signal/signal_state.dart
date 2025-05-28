
import 'package:equatable/equatable.dart';

abstract class SignalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignalInitial extends SignalState {}

class SignalLoading extends SignalState {}

class SignalSuccess extends SignalState {}

class SignalFailure extends SignalState {
  final String message;
  SignalFailure(this.message);

  @override
  List<Object?> get props => [message];
}
