class MessageModel {
  final String senderName;
  final String text;
  final double probability;
  final String time;

  MessageModel({
    required this.senderName,
    required this.text,
    required this.probability,
    required this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      senderName: json['senderName'],
      text: json['text'],
      probability: json['probability'].toDouble(),
      time: json['time'],
    );
  }
}
