import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_model.dart';

class KidProfile {
  final String id;
  final String firstName;
  final String? photoURL;
  final List<MessageModel> flaggedMessages;

  const KidProfile({
    required this.id,
    required this.firstName,
    this.photoURL,
    this.flaggedMessages = const [],
  });

  factory KidProfile.fromMap(
    String id,
    Map<String, dynamic> data, {
    List<MessageModel> flaggedMessages = const [],
  }) {
    return KidProfile(
      id: id,
      firstName: data['name'],
      photoURL: data['profilePhoto'] as String?,
      flaggedMessages: flaggedMessages,
    );
  }

  factory KidProfile.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    List<MessageModel> flaggedMessages = const [],
  }) =>
      KidProfile.fromMap(doc.id, doc.data()!, flaggedMessages: flaggedMessages);

  double get totalMessages => flaggedMessages.length.toDouble();

  String get name => firstName;

  KidProfile copyWith({ List<MessageModel>? flaggedMessages }) {
    return KidProfile(
      id: id,
      firstName: firstName,
      photoURL: photoURL,
      flaggedMessages: flaggedMessages ?? this.flaggedMessages,
    );
  }


}
