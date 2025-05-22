import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/kid_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KidRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<KidProfile>> watchKid(List<String> ids) {
    if (ids.isEmpty) return Stream.value(<KidProfile>[]);
    try {
      if (ids.length <= 10) {
        final kidsCollection = _db.collection('kids');
        final query = kidsCollection.where(FieldPath.documentId, whereIn: ids);
        final snapshots = query.snapshots();
        return snapshots.map(
              (snap) =>
              snap.docs
                  .map((doc) => KidProfile.fromMap(doc.id, doc.data()))
                  .toList(),
        );}else{
        final streams = ids.map((id) =>
            _db.collection('kids').doc(id).snapshots().map(KidProfile.fromDoc)
        );
        return Rx.combineLatestList(streams);
      }
    }catch (e) {
      debugPrint('watchKid error: $e');
      rethrow;
    }
  }
  //
  // Stream<List<KidProfile>> watchKidsWithFlags(List<String> kidIds) {
  //   if (kidIds.isEmpty) return Stream.value([]);
  //
  // }
}
