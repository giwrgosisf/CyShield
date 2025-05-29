import 'package:flutter/material.dart';
import 'package:guardians_app/data/models/kid_profile.dart';

class KidCard extends StatelessWidget {
  final KidProfile kid;
  final Color primaryColor;
  final VoidCallback onRemove;

  const KidCard({
    super.key,
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
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                shape: BoxShape.circle,
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    kid.photoURL != null
                        ? NetworkImage(kid.photoURL!)
                        : const AssetImage('assets/images/austin.png')
                            as ImageProvider,
              ),
            ),
            Positioned(
              right: -8,
              top: -8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    kid.firstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
