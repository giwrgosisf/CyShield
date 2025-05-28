import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/backend_services.dart';
import 'all_done_state.dart';

class AllDoneCubit extends Cubit<AllDoneState> {
  AllDoneCubit() : super(const AllDoneState());
  final BackendServices server = BackendServices(baseUrl:'http://192.168.1.88');

  Future<void> setSignal() async {
    final signal = await server.getSignalState();
    if (kDebugMode) {
      print("Fetched Signal State: $signal");
    }
    emit(state.copyWith(signalActive:  await server.getSignalState()));
  }

  Future<void> setTelegram() async {
    emit(state.copyWith(telegramActive: await server.getTelegramState()));
  }
}