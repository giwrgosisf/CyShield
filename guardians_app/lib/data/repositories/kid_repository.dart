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


  Future<Map<int, Map<String, int>>> getWeeklyMessageCountsForKid(String kidId) async {
    final kidProfile = await _watchKidAndMessages(kidId).first;

    final Map<int, Map<String, int>> weeklyCounts = {};

    final now = DateTime.now();
    // Calculate the start of the current week (Monday)
    DateTime startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    if (now.weekday == DateTime.sunday) { // Adjust for Sunday being 7 in Dart's weekday
      startOfCurrentWeek = now.subtract(const Duration(days: 6));
    }
    startOfCurrentWeek = DateTime(startOfCurrentWeek.year, startOfCurrentWeek.month, startOfCurrentWeek.day);



    for (int i = 0; i < 4; i++) {
      weeklyCounts[i] = {
        'toxic': 0,
        'moderate': 0,
        'healthy': 0,
      };
    }

    for (final message in kidProfile.flaggedMessages) {

      for (int i = 0; i < 4; i++) {
        DateTime weekStart = startOfCurrentWeek.subtract(Duration(days: i * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 7));

        // Adjust weekEnd to be end of day to include messages from the last day of the week
        weekEnd = DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59, 999);


        if (message.time.isAfter(weekStart.subtract(const Duration(milliseconds: 1))) && message.time.isBefore(weekEnd)) {

            weeklyCounts[i]!['toxic'] = await getKidToxicCount(kidId);

            weeklyCounts[i]!['moderate'] = await getKidModerateCount(kidId);

            weeklyCounts[i]!['healthy'] = await getKidHealthyCount(kidId);

        }
      }
    }
    return weeklyCounts;
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

  // In KidRepository.dart



  Future<List<KidProfile>> getKidsByIds(List<String> kidIds) async {
    print('DEBUG: KidRepository - getKidsByIds called with IDs: $kidIds');
    if (kidIds.isEmpty) {
      print('DEBUG: KidRepository - getKidsByIds: input kidIds is empty, returning [].');
      return [];
    }

    try {
      if (kidIds.length <= 10) {
        final QuerySnapshot<Map<String, dynamic>> snapshot = await _db
            .collection('kids')
            .where(FieldPath.documentId, whereIn: kidIds)
            .get();
        print('DEBUG: KidRepository - getKidsByIds (<=10): Firestore query executed.');
        print('DEBUG: KidRepository - getKidsByIds (<=10): Fetched ${snapshot.docs.length} documents.');

        if (snapshot.docs.isEmpty) {
          print('DEBUG: KidRepository - getKidsByIds (<=10): No documents found for IDs: $kidIds');
        }

        return snapshot.docs
            .map((doc) {
          if (!doc.exists || doc.data() == null) {
            print('DEBUG: KidRepository - Doc ${doc.id} does not exist or has no data, skipping.');
            // You might want to return null or throw an error here, or filter it out later
            return null; // Temporarily return null to see if it causes issues later
          }
          print('DEBUG: KidRepository - Mapped doc ${doc.id} to KidProfile.');
          return KidProfile.fromMap(doc.id, doc.data()!);
        })
            .whereType<KidProfile>() // Filter out any nulls if you return null above
            .toList();
      } else {
        print('DEBUG: KidRepository - getKidsByIds (>10): Fetching individually for ${kidIds.length} IDs.');
        final List<Future<KidProfile>> futures = kidIds.map((id) async {
          final DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection('kids').doc(id).get();
          if (doc.exists && doc.data() != null) {
            print('DEBUG: KidRepository - Fetched individual doc for ${id}. Exists: true');
            return KidProfile.fromDoc(doc);
          } else {
            print('DEBUG: KidRepository - Individual doc ${id} does not exist or has no data. Returning default profile.');
            return KidProfile(id: id, firstName: 'Unknown', photoURL: null);
          }
        }).toList();
        final results = await Future.wait(futures);
        print('DEBUG: KidRepository - getKidsByIds (>10): Fetched ${results.length} kids individually.');
        return results;
      }
    } catch (e, st) {
      debugPrint('ERROR: KidRepository - Error getting kids by IDs: $e\n$st');
      // This is crucial: if an error occurs, it means something went wrong with Firestore itself
      // Check logs for specific FirebaseException messages
      return []; // Return an empty list on error
    }
  }

  Future<int> getKidHealthyCount(String kidId) async {
    try {
      final docSnapshot = await _db.collection('kids').doc(kidId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final healthyCount = data['healthy'] as int?; // Cast to int, allow null
        print('DEBUG: Fetched healthy count for kid $kidId: $healthyCount');
        return healthyCount ?? 0; // Return 0 if 'healthy' field is null or not found
      } else {
        print('DEBUG: Kid document with ID $kidId not found or has no data.');
        return 0; // Kid document not found
      }
    } catch (e) {
      debugPrint('ERROR: getKidHealthyCount for $kidId: $e');
      return 0; // Return 0 in case of any error
    }
  }

  Future<int> getKidModerateCount(String kidId) async {
    try {
      final docSnapshot = await _db.collection('kids').doc(kidId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final moderateCount = data['moderate'] as int?; // Cast to int, allow null
        print('DEBUG: Fetched healthy count for kid $kidId: $moderateCount');
        return moderateCount ?? 0; // Return 0 if 'healthy' field is null or not found
      } else {
        print('DEBUG: Kid document with ID $kidId not found or has no data.');
        return 0; // Kid document not found
      }
    } catch (e) {
      debugPrint('ERROR: getKidHealthyCount for $kidId: $e');
      return 0; // Return 0 in case of any error
    }
  }

  Future<int> getKidToxicCount(String kidId) async {
    try {
      final docSnapshot = await _db.collection('kids').doc(kidId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        final toxicCount = data['toxic'] as int?; // Cast to int, allow null
        print('DEBUG: Fetched healthy count for kid $kidId: $toxicCount');
        return toxicCount ?? 0; // Return 0 if 'healthy' field is null or not found
      } else {
        print('DEBUG: Kid document with ID $kidId not found or has no data.');
        return 0; // Kid document not found
      }
    } catch (e) {
      debugPrint('ERROR: getKidHealthyCount for $kidId: $e');
      return 0; // Return 0 in case of any error
    }
  }

}

