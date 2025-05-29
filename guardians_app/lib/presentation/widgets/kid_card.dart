import 'package:flutter/material.dart';
import 'package:guardians_app/data/models/kid_profile.dart';

class KidCard extends StatelessWidget {
  final KidProfile kid;
  final Color primaryColor;
  final VoidCallback onRemove;

  const KidCard({super.key,
    required this.kid,
    required this.primaryColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage:
              kid.photoURL != null
                  ? NetworkImage(kid.photoURL!)
                  : const AssetImage('assets/images/austin.png')
                      as ImageProvider,
        ),
        Positioned(
          right: -4,
          top: -4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(color: Colors.redAccent),
              child: Center(
                child: Icon(Icons.remove, color: Colors.white, size: 24.0),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            kid.firstName,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
