import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/bloc/statistics/statistics_event.dart';
import 'package:guardians_app/bloc/statistics/statistics_state.dart';
import 'package:guardians_app/data/repositories/kid_repository.dart';
import 'package:flutter/material.dart';
import '../../data/models/kid_profile.dart';


class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final KidRepository repository;

  StatisticsBloc(this.repository) : super(StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
      LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(StatisticsLoading());
    try {
      // Ensure the type is explicitly non-nullable List<KidProfile>
      // The `!` is a null assertion operator, telling Dart that we *expect* this to not be null.
      // This is safe because getKidsByIds is designed to return [] on error/empty.
      final List<KidProfile> kids = await repository.getKidsByIds(event.kidIds);
      print('DEBUG: StatisticsBloc - _onLoadStatistics - Fetched kids count from repository: ${kids.length}');


      // This check is still good, even if `kids` is guaranteed non-null,
      // because `getKidsByIds` might return an *empty* list.
      if (kids.isEmpty) {
        print('DEBUG: StatisticsBloc - No kids fetched from repository.');
        emit(StatisticsLoaded(kids: [], weeklyMessageCountsByKid: {}));
        return;
      }

      final Map<String, Map<int, Map<String, int>>> allWeeklyCounts = {};
      for (var kid in kids) {
        // Ensure that getWeeklyMessageCountsForKid also returns a non-nullable Map
        final weeklyCounts = await repository.getWeeklyMessageCountsForKid(kid.id);
        allWeeklyCounts[kid.id] = weeklyCounts;
        print('DEBUG: StatisticsBloc - Fetched weekly counts for ${kid.name} (${kid.id}).');
      }

      emit(StatisticsLoaded(
        kids: kids,
        weeklyMessageCountsByKid: allWeeklyCounts,
      ));
      print('DEBUG: StatisticsBloc - Emitted StatisticsLoaded with ${kids.length} kids.');

    } catch (e, st) {
      debugPrint('Error loading weekly statistics: $e\n$st');
      emit(StatisticsError("Failed to load weekly statistics: $e"));
    }
  }
}