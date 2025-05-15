import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notifications/notifications_cubit.dart';
import '../../core/app_theme.dart';
import '../../data/models/notification_item.dart';

Widget buildRequestsSection(BuildContext ctx, RequestNotification request) {
  final color = request.seen ? AppTheme.readNotification : AppTheme.unreadNotification;
  return Container(
    color: color,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(request.message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    () => ctx.read<NotificationsCubit>().rejectRequest(request),
                child: const Text('Απόρριψη'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    () => ctx.read<NotificationsCubit>().acceptRequest(request),
                child: const Text('Αποδοχή'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
