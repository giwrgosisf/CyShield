import '../../../models/child_model.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final List<ChildModel> children;

  StatisticsLoaded(this.children);
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError(this.message);
}
