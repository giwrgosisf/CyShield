import 'package:equatable/equatable.dart';
import '../../data/models/notification_item.dart';

enum NotificationsStatus { loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<ReportNotification> reports;
  final List<RequestNotification> requests;
  final String? error;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.reports = const [],
    this.requests = const [],
    this.error,
  });

  const NotificationsState.loading()
    : this(status: NotificationsStatus.loading);
  const NotificationsState.success(
    List<ReportNotification> reports,
    List<RequestNotification> requests,
  ) : this(
        status: NotificationsStatus.success,
        reports: reports,
        requests: requests,
      );
  const NotificationsState.failure(String e)
    : this(status: NotificationsStatus.failure, error: e);

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<ReportNotification>? reports,
    List<RequestNotification>? requests,
    String? error,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      requests: requests ?? this.requests,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, reports, requests, error];
}
