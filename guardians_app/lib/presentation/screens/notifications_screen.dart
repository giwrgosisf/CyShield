import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notifications/notifications_cubit.dart';
import '../../bloc/notifications/notifications_state.dart';
import '../../core/app_theme.dart';

import '../widgets/bottom_navbar.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/notifications_report_section.dart';
import '../widgets/notifications_request_section.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _navIndex = 2;

  static const _routes = ['/home', '/family', '/notifications', '/profile'];
  late final NotificationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<NotificationsCubit>();
  }

  @override
  void dispose() {
    _cubit.markAllSeen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cyshield'),
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (ctx, state) {
            if (state.status == NotificationsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }
            if (state.status == NotificationsStatus.failure) {
              return Center(
                child: Text(state.error ?? 'Error loading notifications'),
              );
            }

            final screenHeight = MediaQuery.of(context).size.height;
            final verticalPadding = screenHeight * 0.1;
            return Padding(
              padding: EdgeInsets.only(bottom: verticalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'Ειδοποιήσεις',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  //   Mhnumata
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Μηνύματα',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child:
                        state.reports.isEmpty
                            ? const Center(child: Text('Κανένα νέο μήνυμα'))
                            : ListView.builder(
                              itemCount: state.reports.length,
                              itemBuilder:
                                  (ctx, i) =>
                                      buildReportSection(ctx, state.reports[i]),
                            ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Αιτήματα',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child:
                        state.requests.isEmpty
                            ? const Center(child: Text('Κανένα νέο αίτημα'))
                            : ListView.builder(
                              itemCount: state.requests.length,
                              itemBuilder:
                                  (ctx, i) => buildRequestsSection(
                                    ctx,
                                    state.requests[i],
                                  ),
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: _navIndex,
        onTap: (i) {
          final target = _routes[i];
          // only navigate if we’re not already on that route
          if (ModalRoute.of(context)!.settings.name != target) {
            Navigator.pushReplacementNamed(context, target);
          }
        },
      ),
    );
  }
}
