import 'message_model.dart';

class ChildModel {
  final String name;
  final String avatar; // Path to asset
  final List<MessageModel> flaggedMessages;

  final double safePercent;
  final double moderatePercent;
  final double toxicPercent;


  ChildModel({
    required this.name,
    required this.avatar,
    required this.flaggedMessages,
    this.safePercent = 0.0,
    this.moderatePercent = 0.0,
    this.toxicPercent = 0.0,
  });

  double get totalMessages => flaggedMessages.length.toDouble();

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      name: json['name'],
      avatar: json['avatar'],
      flaggedMessages: (json['flaggedMessages'] as List)
          .map((msg) => MessageModel.fromJson(msg))
          .toList(),
    );
  }
}
