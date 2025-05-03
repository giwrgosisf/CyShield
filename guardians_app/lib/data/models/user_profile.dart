import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String uid;
  final String firstName;
  final String lastName;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
  });


  String get displayName => firstName;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      firstName: data['name'] ?? '',
      lastName: data['surname'] ?? '',
    );
  }

  @override
  List<Object?> get props => [uid, firstName, lastName];

}
