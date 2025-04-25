
import 'package:bloc/bloc.dart';

import 'package:guardians_app/bloc/reports/reports_event.dart';
import 'package:guardians_app/bloc/reports/reports_state.dart';
import '../../../data/repositories/reports_repository.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository reportsRepository;

  ReportsBloc(this.reportsRepository) : super(ReportsInitial()) {
    on<LoadReports>(_onLoadReports);
  }

  Future<void> _onLoadReports(
      LoadReports event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final children = await reportsRepository.getFlaggedReports();
      emit(ReportsLoaded(children));
    } catch (e) {
      emit(ReportsError('Failed to load reports'));
    }
  }
}
