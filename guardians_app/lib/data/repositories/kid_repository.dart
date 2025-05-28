import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:guardians_app/data/models/message_model.dart';
import 'package:rxdart/rxdart.dart';

import '../models/kid_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KidRepository {
  final FirebaseFirestore _db;
  KidRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance {
    _db.settings = const Settings(persistenceEnabled: true);
  }

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
        );
      } else {
        final streams = ids.map(
          (id) => _db
              .collection('kids')
              .doc(id)
              .snapshots()
              .map(KidProfile.fromDoc),
        );
        return Rx.combineLatestList(streams);
      }
    } catch (e) {
      debugPrint('watchKid error: $e');
      rethrow;
    }
  }

  Stream<KidProfile> _watchKidAndMessages(String kidId) {
    final doc = _db.collection('kids').doc(kidId).snapshots().handleError((
      e,
      st,
    ) {
      print('Error loading kid $kidId: $e');
    });
    final flaggedMessages = _db
        .collection('kids')
        .doc(kidId)
        .collection('flaggedMessages')
        .orderBy('time', descending: true)
        .snapshots()
        .handleError((e, st) {
          print('Error loading flagged messages for $kidId: $e');
        });
    return Rx.combineLatest2(doc, flaggedMessages, (
      DocumentSnapshot<Map<String, dynamic>> doc,
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      final docData = doc.data()!;
      final childName = docData['name'] as String? ?? '';
      final mess =
          snap.docs.map((d) {
            final data = d.data();
            return MessageModel(
              childId: kidId,
              messageId: d.id,
              senderName: data['senderName'] as String,
              text: data['text'] as String,
              probability: data['probability'] as double,
              time: (data['time'] as Timestamp).toDate(),
              childName: childName,
            );
          }).toList();

      return KidProfile.fromMap(doc.id, docData, flaggedMessages: mess);
    });
  }

  Stream<List<KidProfile>> watchKidsWithFlags(List<String> kidIds) {
    if (kidIds.isEmpty) return Stream.value(<KidProfile>[]);
    final streams = kidIds.map(_watchKidAndMessages).toList();
    return Rx.combineLatestList<KidProfile>(streams);
  }
}
