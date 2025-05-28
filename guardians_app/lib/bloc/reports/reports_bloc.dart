import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_event.dart';
import 'reports_state.dart';
import '../../data/models/kid_profile.dart';
import '../../data/repositories/reports_repository.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;
  StreamSubscription<List<KidProfile>>? _reportsSubscription;

  ReportsBloc(this._reportsRepository) : super(ReportsInitial()) {
    on<LoadReports>(_onLoadReports);
    on<MarkMessageAsReviewed>(_onMarkMessageAsReviewed);
    on<RefreshReports>(_onRefreshReports);
  }

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    try {
      await _reportsSubscription?.cancel();

      _reportsSubscription = _reportsRepository
          .watchFlaggedReports(event.kidIds)
          .listen(
            (kidsWithFlags) {
              if (!isClosed) {
                emit(ReportsLoaded(kidsWithFlags: kidsWithFlags));
              }
            },
            onError: (error) {
              if (!isClosed) {
                emit(ReportsError('Failed to load reports: $error'));
              }
            },
          );
    } catch (e) {
      emit(ReportsError('Failed to load reports: $e'));
    }
  }

  Future<void> _onMarkMessageAsReviewed(
    MarkMessageAsReviewed event,
    Emitter<ReportsState> emit,
  ) async {
    // TODO: Implement marking message as reviewed in Firestore
    // await _reportsRepository.markMessageAsReviewed(
    //   event.kidId,
    //   event.messageId,
    //   event.isOffensive
    // );
  }

  Future<void> _onRefreshReports(
    RefreshReports event,
    Emitter<ReportsState> emit,
  ) async {
    if (state is ReportsLoaded) {
      final currentState = state as ReportsLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      await Future.delayed(const Duration(milliseconds: 250));

      if (state is ReportsLoaded) {
        final newState = state as ReportsLoaded;
        emit(newState.copyWith(isRefreshing: false));
      }
    }
  }

  @override
  Future<void> close() {
    _reportsSubscription?.cancel();
    return super.close();
  }
}
