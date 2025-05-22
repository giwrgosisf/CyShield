
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
      senderName: map['senderName'] as String? ?? 'Unknown',
      text: map['text'] as String? ?? '',
      probability: (map['probability'] as num?)?.toDouble() ?? 0.0,
      time: (map['time'] as Timestamp).toDate(),
      childName: map['childName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'childId': childId,
    'messageId': messageId,
    'senderName': senderName,
    'text': text,
    'probability': probability,
    'time': Timestamp.fromDate(time),
    'childName': childName,
  };
}