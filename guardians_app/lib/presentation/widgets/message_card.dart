import 'package:flutter/material.dart';
import 'package:guardians_app/core/app_theme.dart';
import 'package:guardians_app/core/containers/strings.dart';
import '../../models/message_model.dart';

class MessageCard extends StatelessWidget {
  final MessageModel message;

  const MessageCard({super.key, required this.message});

  Color getBackgroundColor(double probability) {
    if (probability >= 0.9) return AppTheme.slightlyRed;
    if (probability >= 0.6) return AppTheme.slightlyYellow;
    return Colors.green.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: getBackgroundColor(message.probability),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2.0, color: Colors.black),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipOval(
                  child: Image.asset(
                    "assets/images/profilePicture.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),

                // Right-hand side (message details)
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main message content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message.text,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),


                      Positioned(
                        bottom: 0,
                        left: -70,
                        child: Text(
                          '${(message.probability * 100).toInt()}% Προσβλητικό',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Bottom-right: TIME
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              MyText.harmfulText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 35),
                ),
                child: MyText.yes,
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 35),
                ),
                child: MyText.no,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
