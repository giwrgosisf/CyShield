import 'package:flutter/foundation.dart';

import '../models/kid_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KidRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<KidProfile>> watchKid(List<String> ids) {
    try {
      final kidsCollection = _db.collection('kids');
      final query = kidsCollection.where(FieldPath.documentId, whereIn: ids);
      final snapshots = query.snapshots();
      return snapshots.map(
            (snap) =>
            snap.docs
                .map((doc) => KidProfile.fromMap(doc.id, doc.data()))
                .toList(),
      );
    }catch (e) {
      debugPrint('watchKid error: $e');
      rethrow;
    }
  }
}
