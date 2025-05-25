import 'package:equatable/equatable.dart';

class  KidProfile extends Equatable {
  final String uid;
  final String firstName;
  final String lastName;
  final List<String>? parents;

  const KidProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.parents = const[]
});

  String get displayName => firstName;

  factory KidProfile.fromMap(String uid, Map<String, dynamic> data){
    return KidProfile(
        uid: uid,
        firstName: data['name']?? '',
        lastName: data['surname']??'',
        parents: List<String>.from(data['parents']??[])
    );
  }

  @override
  List<Object?> get props =>[
    uid,
    firstName,
    lastName,
    parents
  ];
}