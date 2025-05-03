import 'package:flutter/material.dart';
import 'package:guardians_app/core/app_theme.dart';

class CardButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const CardButton({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              asset,
              width: 280,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: const Offset(0, 28),
                child: Material(
                  elevation: 8,
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 350,
                      height: 56,
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class CardButton extends StatelessWidget {
//   final String asset;
//   final String label;
//   final VoidCallback onTap;
//
//   const CardButton({
//     super.key,
//     required this.asset,
//     required this.label,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Image.asset(asset, height: 200, fit: BoxFit.cover),
//         ),
//         const SizedBox(height: 6),
//         SizedBox(
//           width: 300,
//           child: FilledButton(
//             style: FilledButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: onTap,
//             child: Text(label),
//           ),
//         ),
//       ],
//     );
//   }
// }