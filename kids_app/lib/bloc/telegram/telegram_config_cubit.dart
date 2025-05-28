import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/telegram/telegram_config_state.dart';
import 'package:kids_app/core/services/backend_services.dart';

class TelegramConfigCubit extends Cubit<TelegramConfigState> {
  final Function(Map<String, String>)? onCodeSent;
  final Function()? onAlreadyAuthorized;

  TelegramConfigCubit({
    this.onCodeSent,
    this.onAlreadyAuthorized,
  }) : super(const TelegramConfigState());

  final BackendServices server = BackendServices(baseUrl:'http://192.168.1.88');

  void updateApiId(String apiId) {
    emit(state.copyWith(apiId: apiId, errorMessage: null));
  }

  void updateApiHash(String apiHash) {
    emit(state.copyWith(apiHash: apiHash, errorMessage: null));
  }

  void updatePhoneNumber(String phoneNumber) {
    emit(state.copyWith(phoneNumber: phoneNumber, errorMessage: null));
  }




  Future<void> submitConfiguration() async {
    if (state.apiId.isEmpty || state.apiHash.isEmpty || state.phoneNumber.isEmpty) {
      emit(state.copyWith(errorMessage: 'Παρακαλώ συμπληρώστε όλα τα πεδία'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await server.sendTelegramCredentials(
        phoneNumber: state.phoneNumber,
        apiHash: state.apiHash,
        apiId: state.apiId,
      );

      switch (result['status']) {
        case 'code_sent':
          emit(state.copyWith(
            isLoading: false,
          ));
          onCodeSent?.call({
            'phone_code_hash': result['phone_code_hash']!,
            'phone_number': state.phoneNumber,
            'api_id': state.apiId,
            'api_hash': state.apiHash,
          });
          break;


        case 'already_authorized':
          emit(state.copyWith(isLoading: false));
          onAlreadyAuthorized?.call();
          break;


        case 'error':
          emit(state.copyWith(
            isLoading: false,
            errorMessage: result['message'] ?? 'Άγνωστο σφάλμα',
          ));
          break;
      }

    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Σφάλμα κατά την αποστολή των στοιχείων στον server',
      ));
    }
  }
}