
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  final String childId, messageId, senderName, text;
  final double probability;
  final DateTime time;
  final String childName;

  MessageModel({
    required this.childId,
    required this.messageId,
    required this.senderName,
    required this.text,
    required this.probability,
    required this.time,
    required this.childName,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      childId: map['childId'] as String,
      messageId: map['messageId'] as String,
      senderName: (map['sender'] ?? map['senderName']) as String? ?? 'Unknown',
      text: map['text'] as String? ?? '',
      probability: ((map['score'] ?? map['probability']) as num?)?.toDouble() ?? 0.0,
      time: (map['timestamp'] ?? map['time']) != null
          ? ((map['timestamp'] ?? map['time']) as Timestamp).toDate()
          : DateTime.now(),
      childName: map['childName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'messageId': messageId,
    'sender': senderName,
    'text': text,
    'score': probability,
    'timestamp': Timestamp.fromDate(time),
    'childName': childName,
  };
}