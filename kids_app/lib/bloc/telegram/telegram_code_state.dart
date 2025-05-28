import 'package:equatable/equatable.dart';

class TelegramCodeState extends Equatable {
  final String phoneNumber;
  final String code;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? successMessage;

  const TelegramCodeState({
    required this.phoneNumber,
    this.code = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.successMessage,
  });

  TelegramCodeState copyWith({
    String? phoneNumber,
    String? code,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? successMessage,
  }) {
    return TelegramCodeState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      code: code ?? this.code,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber,
    code,
    isLoading,
    isSuccess,
    errorMessage,
    successMessage,
  ];
}