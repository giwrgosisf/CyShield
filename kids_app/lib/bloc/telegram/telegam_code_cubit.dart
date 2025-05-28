import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_app/bloc/telegram/telegram_code_state.dart';
import 'package:kids_app/core/services/backend_services.dart';

class TelegramCodeCubit extends Cubit<TelegramCodeState> {
  final String phoneNumber;
  final String apiId;
  final String apiHash;
  final String phoneCodeHash;
  final Function()? onSuccess;
  final Function()? onPasswordRequired;

  TelegramCodeCubit({
    required this.phoneNumber,
    required this.apiId,
    required this.apiHash,
    required this.phoneCodeHash,
    this.onSuccess,
    this.onPasswordRequired,
  }) : super(TelegramCodeState(phoneNumber: phoneNumber));

  final BackendServices server = BackendServices(baseUrl: 'http://192.168.1.88');

  void updateCode(String code) {
    emit(state.copyWith(code: code, errorMessage: null));
  }

  Future<void> verifyCode() async {
    if (state.code.isEmpty) {
      emit(state.copyWith(errorMessage: 'Παρακαλώ εισάγετε τον κωδικό επιβεβαίωσης'));
      return;
    }

    if (state.code.length < 5) {
      emit(state.copyWith(errorMessage: 'Ο κωδικός επιβεβαίωσης πρέπει να έχει τουλάχιστον 5 χαρακτήρες'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await server.confirmTelegramCredentials(
        phoneNumber: phoneNumber,
        apiHash: apiHash,
        apiId: apiId,
        code: state.code,
        phoneCodeHash: phoneCodeHash,
      );

      final status = result['status'] ?? 'unknown';
      print("Verification result: $result"); // Debug log

      switch (status) {
        case 'success':
        case 'already_authorized':
          server.setTelegramState(true);
          emit(state.copyWith(isLoading: false, isSuccess: true));
          onSuccess?.call();
          break;

        case 'password_required':
          emit(state.copyWith(isLoading: false));
          onPasswordRequired?.call();
          break;

        case 'invalid_code':
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Λάθος κωδικός επιβεβαίωσης. Παρακαλώ δοκιμάστε ξανά.',
          ));
          break;

        case 'code_expired':
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Ο κωδικός επιβεβαίωσης έχει λήξει. Παρακαλώ ζητήστε νέο κωδικό.',
          ));
          break;

        case 'error':
          emit(state.copyWith(
            isLoading: false,
            errorMessage: result['message'] ?? 'Άγνωστο σφάλμα',
          ));
          break;

        default:
          emit(state.copyWith(
            isLoading: false,
            errorMessage: 'Σφάλμα κατά την επιβεβαίωση του κωδικού: $status',
          ));
          break;
      }

    } catch (e) {
      print("Error in verifyCode: $e"); // Debug log
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Σφάλμα κατά την επικοινωνία με τον server: ${e.toString()}',
      ));
    }
  }

  Future<void> resendCode() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final result = await server.sendTelegramCredentials(
        phoneNumber: phoneNumber,
        apiHash: apiHash,
        apiId: apiId,
      );

      if (result['status'] == 'code_sent') {
        emit(state.copyWith(
          isLoading: false,
          successMessage: 'Νέος κωδικός επιβεβαίωσης στάλθηκε',
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result['message'] ?? 'Σφάλμα κατά την αποστολή νέου κωδικού',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Σφάλμα κατά την επικοινωνία με τον server: ${e.toString()}',
      ));
    }
  }
}