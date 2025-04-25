import '../../../models/child_model.dart';

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ChildModel> children;

  ReportsLoaded(this.children);
}

class ReportsError extends ReportsState {
  final String message;

  ReportsError(this.message);
}
