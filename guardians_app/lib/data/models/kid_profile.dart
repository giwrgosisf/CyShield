class KidProfile {
  final String id;
  final String firstName;
  final String? photoURL;

  const KidProfile({required this.id, required this.firstName, this.photoURL});

  factory KidProfile.fromMap(String id, Map<String, dynamic> data) {
    return KidProfile(
      id: id,
      firstName: data['name'],
      photoURL: data['profilePhoto'] as String?,
    );
  }
}
