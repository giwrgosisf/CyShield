import 'package:flutter/material.dart';
import 'package:guardians_app/core/app_theme.dart';
//
// class BottomNav extends StatelessWidget {
//   final int current;
//   final ValueChanged<int> onTap;
//
//   const BottomNav({super.key, required this.current, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     const bubbleColor = AppTheme.primary;
//
//     return BottomNavigationBar(
//       currentIndex: current,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: AppTheme.thirdBlue,
//       unselectedItemColor: Colors.black87,
//       backgroundColor: AppTheme.lightGray,
//       showUnselectedLabels: true,
//       items: const [
//         BottomNavigationBarItem(
//           icon: ImageIcon(AssetImage('assets/icons/home.png')),
//           activeIcon: _BubbleIcon('assets/icons/home_white.png', bubbleColor),
//           label: 'Σπίτι',
//         ),
//         BottomNavigationBarItem(
//           icon: ImageIcon(AssetImage('assets/icons/family.png')),
//           activeIcon: _BubbleIcon('assets/icons/family_white.png', bubbleColor),
//           label: 'Οικογένεια',
//         ),
//         BottomNavigationBarItem(
//           icon: ImageIcon(AssetImage('assets/icons/user.png')),
//           activeIcon: _BubbleIcon('assets/icons/user_white.png', bubbleColor),
//           label: 'Λογαριασμός',
//         ),
//       ],
//     );
//   }
// }
//
// class _BubbleIcon extends StatelessWidget {
//   final String path;
//   final Color bubbleColor;
//
//   const _BubbleIcon(this.path, this.bubbleColor);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(color: bubbleColor, shape: BoxShape.circle, ),
//       padding: const EdgeInsets.all(12),
//       child: Image.asset(path, width: 24, height: 24),
//     );
//   }
// }

// ---------------------------------------------------------------------------
//  bottom_navbar_m3.dart
// ---------------------------------------------------------------------------

class BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.navbarBackground, // light‑grey bar fill
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.navbarOutline),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 32,
              indicatorShape: const StadiumBorder(),
              indicatorColor: AppTheme.secondary, // blue bubble
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final sel = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                  color: sel ? AppTheme.thirdBlue : Colors.black,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final sel = states.contains(WidgetState.selected);
                return IconThemeData(
                  // size: sel ? 24 : 22,
                );
              }),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: NavigationBar(
                selectedIndex: current,
                onDestinationSelected: onTap,
                backgroundColor: Colors.transparent,
                destinations: [
                  _navbarIcon(
                    'Σπίτι',
                    'assets/icons/home_white.png',
                    'assets/icons/home.png',
                  ),
                  _navbarIcon(
                    'Οικογένεια',
                    'assets/icons/family_white.png',
                    'assets/icons/family.png',
                  ),
                  _navbarIcon(
                    'Ειδοποιήσεις',
                    'assets/icons/bell_white.png',
                    'assets/icons/bell.png',
                  ),
                  _navbarIcon(
                    'Λογαριασμός',
                    'assets/icons/user_white.png',
                    'assets/icons/user.png',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static NavigationDestination _navbarIcon(
    String label,
    String filled,
    String idle,
  ) {
    return NavigationDestination(
      icon: Image.asset(idle, width: 22, height: 22),
      selectedIcon: Image.asset(filled, width: 24, height: 24),
      label: label,
      tooltip: '',
    );
  }
}
