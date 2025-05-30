
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'reports_event.dart';
import 'reports_state.dart';
import '../../data/models/kid_profile.dart';
import '../../data/repositories/reports_repository.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;

  ReportsBloc(this._reportsRepository) : super(ReportsInitial()) {
    on<LoadReports>(_onLoadReports);
    on<MarkMessageAsReviewed>(_onMarkMessageAsReviewed);
    on<RefreshReports>(_onRefreshReports);

    print('DEBUG: ReportsBloc initialized');
  }

  Future<void> _onLoadReports(
      LoadReports event,
      Emitter<ReportsState> emit,
      ) async {
    print('DEBUG: _onLoadReports called with kidIds: ${event.kidIds}');
    if (isClosed) {
      print('DEBUG: Bloc is already closed, skipping load');
      return;
    }

    emit(ReportsLoading());
    print('DEBUG: Emitted ReportsLoading');

    try {
      print('DEBUG: Starting emit.forEach');
      await emit.forEach<List<KidProfile>>(
        _reportsRepository.watchFlaggedReports(event.kidIds),
        onData: (kidsWithFlags) {
          print('DEBUG: emit.forEach received ${kidsWithFlags.length} kids');
          for (var kid in kidsWithFlags) {
            print('DEBUG: emit.forEach - Kid ${kid.firstName} has ${kid.flaggedMessages.length} flagged messages');
          }
          return ReportsLoaded(kidsWithFlags: kidsWithFlags);
        },
        onError: (error, stackTrace) {
          print('DEBUG: emit.forEach error: $error');
          return ReportsError('Failed to load reports: $error');
        },
      );
      print('DEBUG: emit.forEach completed');
    } catch (e) {
      print('DEBUG: Exception in _onLoadReports: $e');
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
    print('DEBUG: _onRefreshReports called');
    if (state is ReportsLoaded && !isClosed) {
      final currentState = state as ReportsLoaded;
      emit(currentState.copyWith(isRefreshing: true));

      await Future.delayed(const Duration(milliseconds: 250));

      if (!isClosed && state is ReportsLoaded) {
        final newState = state as ReportsLoaded;
        emit(newState.copyWith(isRefreshing: false));
      }
    }
  }
}