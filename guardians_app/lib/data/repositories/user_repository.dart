import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepository {
  Future<UserProfile> fetchCurrentUser();

  Future<void> updateUsername(String newName);
  Future<void> updatePhotoUrl(String url);
  Future<void> deleteProfile();

  Stream<UserProfile> watchCurrentUser();
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<UserProfile> fetchCurrentUser() async {
    final uid = _auth.currentUser!.uid;
    try {
      final snap = await _db.collection('users').doc(uid).get();
      return UserProfile.fromMap(uid, snap.data() ?? {});
    } catch (e) {
      debugPrint('fetchCurrentUser error: $e');
      rethrow;
    }
  }

  @override
  Stream<UserProfile> watchCurrentUser() {
    final user = _auth.currentUser;
    if (user == null){
      return const Stream<UserProfile>.empty();
    }
    final uid = user.uid;
    try {
      return _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snap) => UserProfile.fromMap(uid, snap.data() ?? {}));
    } catch (e) {
      debugPrint('watchCurrentUser error: $e');
      rethrow;
    }
  }

  String get _uid => _auth.currentUser!.uid;


  @override
  Future<void> updateUsername(String newName) {
    return _db.collection('users').doc(_uid).update({'name': newName});
  }

  @override
  Future<void> updatePhotoUrl(String url) {
   return _db.collection('users').doc(_uid).update({'profilePhoto': url});
  }

  @override
  Future<void> deleteProfile() async {
    await _db.collection('users').doc(_uid).delete();     // Firestore
    await _auth.currentUser!.delete();                    // Firebase Auth
  }

}
