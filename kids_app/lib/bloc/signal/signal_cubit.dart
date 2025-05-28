import 'package:bloc/bloc.dart';
import 'package:kids_app/bloc/signal/signal_state.dart';
import '../../core/services/backend_services.dart';


class SignalCubit extends Cubit<SignalState> {
  SignalCubit() : super(SignalInitial());

  final BackendServices server = BackendServices(baseUrl: 'http://192.168.1.88');

  Future<void>activateSignal()async {
    server.setSignalState(true);
  }


  Future<void> confirmConnection() async {
    emit(SignalLoading());
    try {
      await activateSignal();
      emit(SignalSuccess());
    } catch (e) {
      emit(SignalFailure('Κάτι πήγε στραβά. Προσπαθήστε ξανά.'));
    }
  }

}
