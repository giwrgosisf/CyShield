import 'package:equatable/equatable.dart';

class TelegramConfigState extends Equatable {
  final String apiId;
  final String apiHash;
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;

  const TelegramConfigState({
    this.apiId = '',
    this.apiHash = '',
    this.phoneNumber = '',
    this.isLoading = false,
    this.errorMessage,
  });

  TelegramConfigState copyWith({
    String? apiId,
    String? apiHash,
    String? phoneNumber,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TelegramConfigState(
      apiId: apiId ?? this.apiId,
      apiHash: apiHash ?? this.apiHash,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [apiId, apiHash, phoneNumber, isLoading, errorMessage];
}
