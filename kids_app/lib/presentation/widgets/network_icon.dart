import 'package:flutter/material.dart';
import 'package:kids_app/core/app_theme.dart';


class IconLabelButton extends StatelessWidget {
  final String assetPath;
  final double circleDiameter;
  final double iconDiameter;
  final Color backgroundColor;
  final String label;
  final TextStyle? labelStyle;
  final double spacing;

  const IconLabelButton({
    super.key,
    required this.assetPath,
    required this.label,
    this.circleDiameter = 80.0,
    this.iconDiameter = 50.0,
    this.backgroundColor = AppTheme.secondary,
    this.labelStyle,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleDiameter,
          height: circleDiameter,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                assetPath,
                width: iconDiameter,
                height: iconDiameter,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }
}

