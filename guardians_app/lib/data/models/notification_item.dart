import 'package:equatable/equatable.dart';

abstract class NotificationItem extends Equatable {
  const NotificationItem();

  String get id;
  String get message;
  DateTime get timestamp;
  bool get seen;
}

class ReportNotification extends NotificationItem {
  final String id;
  final String reportId;
  final String message;
  final DateTime timestamp;
  final bool seen;

  const ReportNotification({
    required this.id,
    required this.reportId,
    required this.message,
    required this.timestamp,
    required this.seen,
  }) : super();

  @override
  List<Object?> get props => [id, reportId, message, timestamp, seen];
}

class RequestNotification extends NotificationItem {
  final String id;
  final String kidId;
  final String kidName;
  final DateTime timestamp;
  final bool seen;

  const RequestNotification({
    required this.id,
    required this.kidId,
    required this.kidName,
    required this.timestamp,
    required this.seen,
  }) : super();

  @override
  String get message => 'Το παιδί $kidName θέλει να σε προσθέσει ως γονέα.';

  @override
  List<Object?> get props => [id, kidId, kidName, timestamp, seen];
}
