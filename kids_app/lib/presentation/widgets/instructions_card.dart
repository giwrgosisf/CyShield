import 'package:flutter/material.dart';
import 'package:kids_app/core/app_theme.dart';


class InstructionItem {
  final String text;
  final bool isBold;
  final double spacingAfter;

  InstructionItem({
    required this.text,
    this.isBold = false,
    this.spacingAfter = 8.0,
  });
}


class InstructionsCard extends StatelessWidget {
  final List<InstructionItem> instructions;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;

  const InstructionsCard({
    super.key,
    required this.instructions,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = AppTheme.secondary,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(instructions.length * 2 - 1, (index) {
          // Even indices: instruction text
          if (index.isEven) {
            final item = instructions[index ~/ 2];
            return Text(
              item.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight:
                item.isBold ? FontWeight.bold : FontWeight.w500,
              ),
            );
          } else {
            // Odd indices: spacing between items
            final prevItem = instructions[(index - 1) ~/ 2];
            return SizedBox(height: prevItem.spacingAfter);
          }
        }),
      ),
    );
  }
}


