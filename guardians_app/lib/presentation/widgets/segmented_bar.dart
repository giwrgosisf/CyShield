import 'package:flutter/material.dart';

class Segment {
  final Color color;
  final double value;

  Segment({required this.color, required this.value});
}

class SegmentedBar extends StatelessWidget {
  final List<Segment> segments;
  final double height;

  const SegmentedBar({super.key, required this.segments, this.height = 30});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: segments
            .map((seg) => Expanded(
          flex: (seg.value * 100).round(),
          child: Container(
            height: height,
            color: seg.color,
          ),
        ))
            .toList(),
      ),
    );
  }
}
