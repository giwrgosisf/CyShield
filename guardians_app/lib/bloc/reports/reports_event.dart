import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadReports extends ReportsEvent {
  final List<String> kidIds;

  const LoadReports(this.kidIds);

  @override
  List<Object> get props => [kidIds];
}

class MarkMessageAsReviewed extends ReportsEvent {
  final String kidId;
  final String messageId;
  final bool isOffensive;

  const MarkMessageAsReviewed({
    required this.kidId,
    required this.messageId,
    required this.isOffensive,
  });

  @override
  List<Object> get props => [kidId, messageId, isOffensive];
}

class RefreshReports extends ReportsEvent {
  const RefreshReports();
}