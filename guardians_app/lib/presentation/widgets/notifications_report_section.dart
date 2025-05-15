import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notifications/notifications_cubit.dart';
import '../../core/app_theme.dart';
import '../../data/models/notification_item.dart';


Widget buildReportSection(BuildContext ctx, ReportNotification report) {
  final color = report.seen ? AppTheme.readNotification : AppTheme.unreadNotification;
  return InkWell(
    onTap: () {
      ctx.read<NotificationsCubit>().markReportSeen(report);
      Navigator.pushNamed(ctx, '/reports'); // or details
    },
    child: Container(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(report.message, style: const TextStyle(fontSize: 16)),
    ),
  );
}