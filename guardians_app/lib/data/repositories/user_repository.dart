import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepository {
  Future<UserProfile> fetchCurrentUser();

  Future<void> updateUsername(String newName);
  Future<void> updatePhotoUrl(String url);
  Future<void> deleteProfile();

  Future<void> addKid(String kidId);
  Future<void> removeKid(String kidId);

  // Future<void> sendKidRequest(String childId);
  // Future<void> rejectKidRequest(String childId);
  // Future<void> acceptKidRequest(String childId);

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
    if (user == null) {
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
    await _db.collection('users').doc(_uid).delete(); // Firestore
    await _auth.currentUser!.delete(); // Firebase Auth
  }

  @override
  Future<void> addKid(String kidId) {
    return _db.collection('users').doc(_uid).update({
      'kids': FieldValue.arrayUnion([kidId]),
    });
  }

  @override
  Future<void> removeKid(String kidId) async{
    try{
      final batch = _db.batch();

      final parentRef = _db.collection('users').doc(_uid);
      batch.update(parentRef, {
        'kids': FieldValue.arrayRemove([kidId]),
      });

      final kidRef = _db.collection('kids').doc(kidId);
      batch.update(kidRef, {
        'parents': FieldValue.arrayRemove([_uid]),
      });

      await batch.commit();
    }catch (e){
      debugPrint('removeKid error: $e');
      rethrow;

    }

  }

  // @override
  // Future<void> sendKidRequest(String childId) {
  //   return _db.collection('users').doc(_uid).update({
  //     'pendingKids': FieldValue.arrayUnion([childId]),
  //   });
  // }
  //
  // @override
  // Future<void> rejectKidRequest(String childId) {
  //   return _db.collection('users').doc(_uid).update({
  //     'pendingKids': FieldValue.arrayRemove([childId]),
  //   });
  // }
  //
  // @override
  // Future<void> acceptKidRequest(String childId) {
  //   return _db.collection('users').doc(_uid).update({
  //     'pendingKids': FieldValue.arrayRemove([childId]),
  //     'kids': FieldValue.arrayUnion([childId]),
  //   });
  // }
}
