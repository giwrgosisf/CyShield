// lib/presentation/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardians_app/core/app_theme.dart';
import 'package:guardians_app/core/containers/strings.dart';
import 'package:guardians_app/presentation/widgets/custom_appbar.dart';
// import 'package:guardians_app/presentation/screens/reports_screen.dart'; // ReportsScreen might not be directly navigated to from here
import '../../bloc/reports/reports_bloc.dart'; // Keep if used elsewhere
import '../../bloc/reports/reports_event.dart'; // Keep if used elsewhere
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';
import '../widgets/weekly_message_chart.dart';
import '../../data/repositories/reports_repository.dart'; // Keep if used elsewhere
import '../../data/repositories/kid_repository.dart';


class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<String> kidIds = []; // <<< Make sure this is `List<String>` and not `List<String>?`
  bool _hasTriggeredLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasTriggeredLoad) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      print('DEBUG: StatisticsScreen - didChangeDependencies - raw args: $args');
      if (args != null && args['kidIds'] != null) {
        // Ensure that args['kidIds'] is indeed a List<String>
        // Use `as List<String>` or `List<String>.from` with a check
        try {
          kidIds = List<String>.from(args['kidIds']);
          print('DEBUG: StatisticsScreen - didChangeDependencies - extracted kidIds: $kidIds');
          if (kidIds.isNotEmpty) {
            print('DEBUG: StatisticsScreen - didChangeDependencies - kidIds are NOT empty, will trigger LoadStatistics.');
            _hasTriggeredLoad = true; // Set to true only if kidIds are successfully extracted
          } else {
            print('DEBUG: StatisticsScreen - didChangeDependencies - kidIds list is empty AFTER List.from conversion.');
          }
        } catch (e) {
          print('ERROR: StatisticsScreen - didChangeDependencies - Failed to cast args["kidIds"] to List<String>: $e');
          kidIds = []; // Ensure it's an empty list on error
        }
      } else {
        print('DEBUG: StatisticsScreen - didChangeDependencies - No kidIds found in arguments (args is null or args["kidIds"] is null).');
        kidIds = []; // Ensure it's an empty list if arguments are missing
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'CyShield'),
      body: BlocProvider(
        create: (context) => StatisticsBloc(KidRepository())..add(LoadStatistics(kidIds)),
        child: Column(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
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
                          MyText.statistics,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                  } else if (state is StatisticsLoaded) {
                    if (state.kids.isEmpty) {
                      return const Center(child: Text('No kids selected for statistics.'));
                    }

                    // This is where the loop for 'kid' should be.
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Iterate through each kid and display their chart
                          // 'kid' is defined within this for-loop scope
                          for (var kid in state.kids)
                            _buildKidStatisticsSection(context, kid.name, state.weeklyMessageCountsByKid[kid.id] ?? {}),
                          const SizedBox(height: 20),
                          _buildLegend(), // Add a legend for the colors
                        ],
                      ),
                    );
                  } else if (state is StatisticsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Select a kid to view statistics.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This helper function builds the section for a single kid's statistics.
  Widget _buildKidStatisticsSection(BuildContext context, String kidName, Map<int, Map<String, int>> weeklyMessageCounts) {
    bool hasData = weeklyMessageCounts.values.any((weekData) =>
    (weekData['toxic'] ?? 0) > 0 ||
        (weekData['moderate'] ?? 0) > 0 ||
        (weekData['healthy'] ?? 0) > 0
    );

    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'No message data available for $kidName for the last 4 weeks.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Εβδομαδιαία στατιστικά για το παιδί: $kidName',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        // Here, weeklyMessageCounts is the specific data for the current kid
        WeeklyMessageChart(weeklyMessageCounts: weeklyMessageCounts),
        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }

  Widget _buildLegend() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.square, color: Colors.red),
              SizedBox(width: 8),
              Text('Toxic Messages'),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.square, color: Colors.yellow),
              SizedBox(width: 8),
              Text('Moderate Messages'),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.square, color: Colors.green),
              SizedBox(width: 8),
              Text('Healthy Messages'),
            ],
          ),
        ],
      ),
    );
  }
}