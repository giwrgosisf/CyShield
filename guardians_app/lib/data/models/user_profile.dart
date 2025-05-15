import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String firstName;
  final String lastName;
  final String? profilePhoto;
  final List<String>? kids;
  final List<String> pendingKids;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
    this.kids = const [],
    this.pendingKids = const [],
  });

  String get displayName => firstName;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      firstName: data['name'] ?? '',
      lastName: data['surname'] ?? '',
      profilePhoto: data['profilePhoto'] as String?,
      kids: List<String>.from(data['kids'] ?? []),
      pendingKids: List<String>.from(data['pendingKids'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    uid,
    firstName,
    lastName,
    profilePhoto,
    kids,
    pendingKids,
  ];
}
