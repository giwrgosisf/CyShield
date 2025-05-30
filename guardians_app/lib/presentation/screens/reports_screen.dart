import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/presentation/screens/statistics_screen.dart';

import '../../bloc/reports/reports_bloc.dart';
import '../../bloc/reports/reports_event.dart';
import '../../bloc/reports/reports_state.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../core/app_theme.dart';
import '../../core/containers/strings.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/models/kid_profile.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/message_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<String> kidIds = [];
  bool _hasTriggeredLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasTriggeredLoad) {
      // Extract arguments passed from navigation
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['kidIds'] != null) {
        kidIds = List<String>.from(args['kidIds']);

        // Trigger loading reports when we first get the kidIds
        if (kidIds.isNotEmpty) {
          print('DEBUG: Triggering LoadReports with kidIds: $kidIds');
          context.read<ReportsBloc>().add(LoadReports(kidIds));
          _hasTriggeredLoad = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cyshield'),
      body: SafeArea(
        child: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            print('DEBUG: BlocBuilder state: $state');
            if (state is ReportsInitial || state is ReportsLoading) {
              print('DEBUG: Showing loading indicator');
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is ReportsError) {
              print('DEBUG: Showing error state: ${state.message}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Σφάλμα φόρτωσης αναφορών',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportsBloc>().add(LoadReports(kidIds));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Δοκιμάστε ξανά'),
                    ),
                  ],
                ),
              );
            }
            if (state is ReportsLoaded) {
              print('DEBUG: ReportsLoaded state received');
              print('DEBUG: All kids count: ${state.kidsWithFlags.length}');

              // Debug each kid
              for (var kid in state.kidsWithFlags) {
                print(
                  'DEBUG: Kid ${kid.firstName} has ${kid.flaggedMessages.length} flagged messages',
                );
              }

              final kidsWithFlags = state.kidsWithFlaggedMessages;
              print(
                'DEBUG: Kids with non-empty flags: ${kidsWithFlags.length}',
              );

              if (kidsWithFlags.isEmpty) {
                print('DEBUG: No kids with flags, showing empty state');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Δεν υπάρχουν αναφορές',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Όλα τα παιδιά σας είναι ασφαλή!',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      // Debug info
                      if (state.kidsWithFlags.isNotEmpty)
                        Text(
                          'DEBUG: Found ${state.kidsWithFlags.length} kids total, but none with flagged messages',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                );
              }
              print(
                'DEBUG: Showing reports list with ${kidsWithFlags.length} kids',
              );
              return RefreshIndicator(
                color: AppTheme.secondary,
                onRefresh: () async {
                  context.read<ReportsBloc>().add(const RefreshReports());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: kidsWithFlags.length,
                  itemBuilder: (context, index) {
                    final kid = kidsWithFlags[index];
                    print(
                      'DEBUG: Building child report for ${kid.firstName} with ${kid.flaggedMessages.length} messages',
                    );
                    return _buildChildReports(context, kid);
                  },
                ),
              );
            }
            print('DEBUG: Fallback - returning empty SizedBox');
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildChildReports(BuildContext context, KidProfile child) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 36),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    child.firstName,
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: child.flaggedMessages.length,
                  itemBuilder: (context, index) {
                    final message = child.flaggedMessages[index];
                    return MessageCard(
                      message: message,
                      onYesPressed: () {
                        context.read<ReportsBloc>().add(
                          MarkMessageAsReviewed(
                            kidId: message.childId,
                            messageId: message.messageId,
                            isOffensive: true,
                          ),
                        );
                      },
                      onNoPressed: () {
                        context.read<ReportsBloc>().add(
                          MarkMessageAsReviewed(
                            kidId: message.childId,
                            messageId: message.messageId,
                            isOffensive: false,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: -60,
            left: -25,
            child: ClipOval(
              child:
                  child.photoURL != null
                      ? Image.network(
                        child.photoURL!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar(child.firstName);
                        },
                      )
                      : Image.asset(
                        'assets/images/austin.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDefaultAvatar(String name) {
  return Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.7),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 60,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
