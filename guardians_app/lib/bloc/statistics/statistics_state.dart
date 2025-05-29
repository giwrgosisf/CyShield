import 'package:flutter/material.dart';
import 'package:guardians_app/data/models/kid_profile.dart';

@immutable
abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  // Now holds a map where the key is kidId and the value is the weekly message counts for that kid
  final Map<String, Map<int, Map<String, int>>> weeklyMessageCountsByKid;
  final List<KidProfile> kids; // The list of KidProfiles for whom statistics are loaded
  final bool isRefreshing;

  StatisticsLoaded({
    this.isRefreshing = false,
    required this.kids,
    required this.weeklyMessageCountsByKid,
  });

  @override
  List<Object> get props => [weeklyMessageCountsByKid, kids, isRefreshing];

  // Similar to ReportsLoaded's copyWith
  StatisticsLoaded copyWith({
    Map<String, Map<int, Map<String, int>>>? weeklyMessageCountsByKid,
    List<KidProfile>? kid,
    bool? isRefreshing,
  }) {
    return StatisticsLoaded(
      weeklyMessageCountsByKid: weeklyMessageCountsByKid ?? this.weeklyMessageCountsByKid,
      kids: kids ?? this.kids,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }


  // --- New getters similar to ReportsLoaded ---

  /// Returns a list of KidProfile objects for kids that have any recorded statistics (toxic, moderate, or healthy messages).
  List<KidProfile> get kidsWithStatistics {
    return kids.where((kid) {
      final counts = weeklyMessageCountsByKid[kid.id];
      if (counts == null) return false;
      // Check if any week has any message counts
      return counts.values.any((weekData) =>
      (weekData['toxic'] ?? 0) > 0 ||
          (weekData['moderate'] ?? 0) > 0 ||
          (weekData['healthy'] ?? 0) > 0);
    }).toList();
  }

  /// Calculates the total number of toxic messages across all kids for the last 4 weeks.
  int get totalToxicMessages {
    return weeklyMessageCountsByKid.values.fold(0, (totalSum, kidWeeklyCounts) {
      return totalSum + kidWeeklyCounts.values.fold(0, (weekSum, weekData) {
        return weekSum + (weekData['toxic'] ?? 0);
      });
    });
  }

  /// Calculates the total number of moderate messages across all kids for the last 4 weeks.
  int get totalModerateMessages {
    return weeklyMessageCountsByKid.values.fold(0, (totalSum, kidWeeklyCounts) {
      return totalSum + kidWeeklyCounts.values.fold(0, (weekSum, weekData) {
        return weekSum + (weekData['moderate'] ?? 0);
      });
    });
  }

  /// Calculates the total number of healthy messages across all kids for the last 4 weeks.
  int get totalHealthyMessages {
    return weeklyMessageCountsByKid.values.fold(0, (totalSum, kidWeeklyCounts) {
      return totalSum + kidWeeklyCounts.values.fold(0, (weekSum, weekData) {
        return weekSum + (weekData['healthy'] ?? 0);
      });
    });
  }

  /// Returns true if there are any statistics (toxic, moderate, or healthy messages) recorded across all kids.
  bool get hasAnyStatistics =>
      totalToxicMessages > 0 || totalModerateMessages > 0 || totalHealthyMessages > 0;
}

class StatisticsError extends StatisticsState {
  final String message;
  StatisticsError(this.message);

  @override
  List<Object> get props => [message];
}