import 'package:flutter/foundation.dart';

import '../models/kid_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class KidRepository {
  Future<KidProfile> fetchCurrentUser();
  //Future<void> sendParentRequest(String childId);
  Stream<KidProfile> watchCurrentUser();
}

class FirebaseUserRepository implements KidRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<KidProfile> fetchCurrentUser() async {
    final uid = _auth.currentUser!.uid;
    try {
      final snap = await _db.collection('kid').doc(uid).get();
      return KidProfile.fromMap(uid, snap.data() ?? {});
    } catch (e) {
      debugPrint('fetchCurrentUser error: $e');
      rethrow;
    }
  }

  @override
  Stream<KidProfile> watchCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<KidProfile>.empty();
    }
    final uid = user.uid;
    try {
      return _db
          .collection('kids')
          .doc(uid)
          .snapshots()
          .map((snap) => KidProfile.fromMap(uid, snap.data() ?? {}));
    } catch (e) {
      debugPrint('watchCurrentUser error: $e');
      rethrow;
    }
  }

  String get _uid => _auth.currentUser!.uid;


}
