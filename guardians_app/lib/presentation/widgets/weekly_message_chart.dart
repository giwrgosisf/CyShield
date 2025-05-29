// lib/presentation/widgets/weekly_message_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyMessageChart extends StatelessWidget {
  final Map<int, Map<String, int>> weeklyMessageCounts;

  const WeeklyMessageChart({
    super.key,
    required this.weeklyMessageCounts,
  });

  @override
  Widget build(BuildContext context) {
    // 1) Find the max Y for scaling
    int maxY = 0;
    for (final weekData in weeklyMessageCounts.values) {
      final total = (weekData['toxic'] ?? 0) +
          (weekData['moderate'] ?? 0) +
          (weekData['healthy'] ?? 0);
      if (total > maxY) maxY = total;
    }
    maxY = (maxY * 1.2).ceil();
    if (maxY == 0) maxY = 10;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBorderRadius: BorderRadius.circular(6),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                tooltipMargin: 4,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final week = group.x.toInt();
                  final weekLabel = week == 0
                      ? 'This Week'
                      : '$week Week${week > 1 ? 's' : ''} Ago';
                  final value = (rod.toY - rod.fromY).toInt();

                  late final String type;
                  late final Color color;
                  if (rodIndex == 0) {
                    type = 'Healthy';
                    color = Colors.green;
                  } else if (rodIndex == 1) {
                    type = 'Moderate';
                    color = Colors.yellow;
                  } else {
                    type = 'Toxic';
                    color = Colors.red;
                  }

                  return BarTooltipItem(
                    '$weekLabel\n$type: $value',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: getBottomTitles,
                  reservedSize: 42,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: getLeftTitles,
                  interval: maxY / 4 < 1 ? 1 : (maxY / 4).ceilToDouble(),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: _buildBarGroups(),
            gridData: const FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(4, (i) {
      final weekData = weeklyMessageCounts[i] ??
          {'toxic': 0, 'moderate': 0, 'healthy': 0};
      final toxic = (weekData['toxic'] ?? 0).toDouble();
      final moderate = (weekData['moderate'] ?? 0).toDouble();
      final healthy = (weekData['healthy'] ?? 0).toDouble();

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: healthy + moderate + toxic,
            width: 22,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            rodStackItems: [
              BarChartRodStackItem(0, healthy, Colors.green),
              BarChartRodStackItem(healthy, healthy + moderate, Colors.yellow),
              BarChartRodStackItem(
                healthy + moderate,
                healthy + moderate + toxic,
                Colors.red,
              ),
            ],
          ),
        ],
      );
    });
  }

  static Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final text = switch (value.toInt()) {
      0 => const Text('This Week', style: style, textAlign: TextAlign.center),
      1 => const Text('1 Week\nAgo', style: style, textAlign: TextAlign.center),
      2 => const Text('2 Weeks\nAgo', style: style, textAlign: TextAlign.center),
      3 => const Text('3 Weeks\nAgo', style: style, textAlign: TextAlign.center),
      _ => const Text('', style: style),
    };

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: text,
    );
  }

  static Widget getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    if (value == meta.max) return const SizedBox.shrink();

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(value.toInt().toString(), style: style),
    );
  }
}
