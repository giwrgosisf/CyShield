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
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              kid.photoURL != null
                  ? NetworkImage(kid.photoURL!)
                  : const AssetImage('assets/images/austin.png')
                      as ImageProvider,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(Icons.remove, color: Colors.white, size: 20),
              ),
            ),
          ),
      ]
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            kid.firstName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
