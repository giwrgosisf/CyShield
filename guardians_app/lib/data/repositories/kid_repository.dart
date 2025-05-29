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
    print('DEBUG: _watchKidAndMessages called for kidId: $kidId');
    final doc = _db.collection('kids').doc(kidId).snapshots().handleError((
      e,
      st,
    ) {
      print('Error loading kid $kidId: $e');
    });
    final flaggedMessages = _db
        .collection('kids')
        .doc(kidId)
        .collection('flaggedmessages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((e, st) {
          print('Error loading flagged messages for $kidId: $e');
        });
    return Rx.combineLatest2(doc, flaggedMessages, (
      DocumentSnapshot<Map<String, dynamic>> doc,
      QuerySnapshot<Map<String, dynamic>> snap,
    ) {
      print('DEBUG: Processing data for kidId: $kidId, doc exists: ${doc.exists}');
      if (!doc.exists || doc.data() == null) {
        print('DEBUG: Document does not exist or has no data for kidId: $kidId');
        return KidProfile(
          id: kidId,
          firstName: 'Unknown',
          photoURL: null,
          flaggedMessages: [],
        );
      }
      final docData = doc.data()!;
      final childName = docData['name'] as String? ?? '';
      print('DEBUG: Found ${snap.docs.length} flagged messages for $childName');
      final mess =
          snap.docs.map((d) {
            try {
              final data = d.data();
              return MessageModel(
                childId: kidId,
                messageId: d.id,
                senderName: data['sender'] as String? ?? 'Unknown',
                text: data['text'] as String? ?? '',
                probability: (data['score'] as num?)?.toDouble() ?? 0.0,
                time: data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).toDate()
                    : DateTime.now(),
                childName: childName,
              );
            } catch (e) {
              print('DEBUG: Error parsing message ${d.id}: $e');
              // Return a default message or skip this message
              return MessageModel(
                childId: kidId,
                messageId: d.id,
                senderName: 'Unknown',
                text: 'Error loading message',
                probability: 0.0,
                time: DateTime.now(),
                childName: childName,
              );
            }
          }).toList();

      final kidProfile = KidProfile.fromMap(doc.id, docData, flaggedMessages: mess);
      print('DEBUG: Created KidProfile for ${kidProfile.firstName} with ${mess.length} flagged messages');
      return kidProfile;
    });
  }

  Stream<List<KidProfile>> watchKidsWithFlags(List<String> kidIds) {
    print('DEBUG: watchKidsWithFlags called with kidIds: $kidIds');
    if (kidIds.isEmpty) return Stream.value(<KidProfile>[]);
    final streams = kidIds.map(_watchKidAndMessages).toList();
    return Rx.combineLatestList<KidProfile>(streams).handleError((error) {
      print('DEBUG: Error in watchKidsWithFlags: $error');
      // Return empty list on error to prevent infinite loading
      return <KidProfile>[];
    });
  }
}
