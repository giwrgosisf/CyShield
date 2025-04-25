import 'package:flutter_bloc/flutter_bloc.dart';
import '../statistics/statistics_event.dart';
import '../statistics/statistics_state.dart';
import '../../../data/repositories/reports_repository.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final ReportsRepository repository;

  StatisticsBloc(this.repository) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      final children = await repository.getFlaggedReports();
      emit(StatisticsLoaded(children));
    } catch (e) {
      emit(StatisticsError("Failed to load statistics"));
    }
  }
}
