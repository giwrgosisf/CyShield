import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notification_item.dart';
import '../../data/repositories/notifications_repository.dart';
import 'notifications_state.dart';


class NotificationsCubit extends Cubit<NotificationsState>{
  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  NotificationsCubit(this._repository):super(const NotificationsState.loading()){
    _subscription = _repository.watchNotifications().listen((all){
      final reports = all.whereType<ReportNotification>().toList();
      final request = all.whereType<RequestNotification>().toList();


      // emitting so we don't lose old reports or requests
      emit(state.copyWith(
        status: NotificationsStatus.success,
        reports: reports,
        requests: request
      ));
    }, onError: (e){
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        error: e.toString()
      ));
    });
  }

  Future<void> markAllSeen() => _repository.markAllSeen();

  Future<void> markReportSeen(ReportNotification report) => _repository.markSeen(report.id);

  Future<void> acceptRequest(RequestNotification request) => _repository.acceptRequest(request.id, request.kidId);

  Future<void> rejectRequest(RequestNotification request) => _repository.rejectRequest(request.id);

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}