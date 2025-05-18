import 'package:flutter/material.dart';
import '../../core/app_theme.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context){
    return AppBar(
      backgroundColor: AppTheme.secondary,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {},
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
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
        title,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight+4);
}