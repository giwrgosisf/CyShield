// child_statistics_card.dart
import 'package:flutter/material.dart';
import 'package:guardians_app/core/app_theme.dart';
import 'package:guardians_app/core/containers/strings.dart';
import '../../models/child_model.dart';
import 'segmented_bar.dart';
import 'legend_item.dart';

class ChildStatisticsCard extends StatelessWidget {
  final ChildModel child;

  const ChildStatisticsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 27, horizontal: 20),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                child.name,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                MyText.lastMonthMessages,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedBar(
                segments: [
                  Segment(color: Colors.green, value: child.safePercent),
                  Segment(color: Colors.amber, value: child.moderatePercent),
                  Segment(color: Colors.red, value: child.toxicPercent),
                ],
              ),

              const SizedBox(height: 16),
              LegendItem(
                color: Colors.green,
                label: '${(child.safePercent * 100).toInt()}% μη προσβλητικά',
              ),
              LegendItem(
                color: Colors.amber,
                label: '${(child.moderatePercent * 100).toInt()}% προσβλητικά',
              ),
              LegendItem(
                color: Colors.red,
                label:
                    '${(child.toxicPercent * 100).toInt()}% άκρως προσβλητικά',
              ),
            ],
          ),
          Positioned(
            top: -90,
            left: -40,
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
