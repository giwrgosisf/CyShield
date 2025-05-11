

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/presentation/screens/statistics_screen.dart';

import '../../bloc/reports/reports_bloc.dart';
import '../../bloc/reports/reports_state.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../core/app_theme.dart';
import '../../core/containers/strings.dart';
import '../../data/repositories/reports_repository.dart';
import '../../models/child_model.dart';
import '../widgets/message_card.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final reportsRepository = ReportsRepository();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //create: (_) => ReportsBloc(reportsRepository)..add(LoadReports()),
      create: (_) => ReportsBloc(context.read<ReportsRepository>()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.secondary,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {},
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('Settings'),
                ),
                const PopupMenuItem<String>(
                  value: 'help',
                  child: Text('Help'),
                ),
              ],
            ),
          ],
          elevation: 10,
          shadowColor: Colors.black.withAlpha((255).round()),
          title: Text(
            MyText.appTitle,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ArbutusSlab',
              fontSize: 30,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          MyText.reports,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => StatisticsBloc(reportsRepository)..add(LoadStatistics()),
                              child: StatisticsScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  } else if (state is ReportsLoaded) {
                    return ListView.builder(
                      itemCount: state.children.length,
                      itemBuilder: (context, index) {
                        final child = state.children[index];
                        return _buildChildReports(child);
                      },
                    );
                  } else if (state is ReportsError) {
                    return Center(child: Text(state.message));
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildReports(ChildModel child) {
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
                    child.name,
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
                    return MessageCard(message: message);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: -60,
            left: -25,
            child: ClipOval(
              child: Image.asset(
                child.avatar,
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
