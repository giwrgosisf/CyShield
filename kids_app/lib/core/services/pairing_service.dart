// pairing_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/kid_profile.dart';
import '../../data/models/pairing_request.dart';

class PairingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  String get _uid => _auth.currentUser!.uid;

  /// Sends a pairing request to the guardian's app
  Future<void> sendPairingRequest({
    required String parentId,
    required KidProfile kidProfile,
  }) async {
    // Create the pairing request
    final pairingRequest = PairingRequest(
      childId: _uid,
      childName: kidProfile.firstName,
      parentId: parentId,
      timestamp: DateTime.now(),
      status: 'pending',
    );

    // Create notification document for the guardian
    final notificationData = {
      'type': 'guardian_request',
      'kidId': _uid,
      'kidName': kidProfile.firstName,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
      'requestId': pairingRequest.id,
      'body':
          '${kidProfile.firstName} wants to connect with you as their guardian',
    };


    final batch = _db.batch();


    final guardianNotificationRef = _db
        .collection('users')
        .doc(parentId)
        .collection('notifications')
        .doc(_uid);

    batch.set(guardianNotificationRef, notificationData);

    final guardianRef = _db.collection('users').doc(parentId);
    batch.update(guardianRef, {
      'pendingKids': FieldValue.arrayUnion([kidProfile.uid]),
    });

    // Store the pairing request for tracking

    // Commit the batch
    await batch.commit();
  }


  Future<bool> doesGuardianExist(String parentId) async {
    try {
      final doc = await _db.collection('users').doc(parentId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> notifyParentOfPairing({
    required String parentFcmToken,
    required String kidName,
  }) async {

  }

  Stream<String> watchPairingRequestStatus({
    required String parentId,
    required String kidId,
  }) {
    return _db
        .collection('users')
        .doc(parentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return 'rejected';
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final pendingKids = List<String>.from(data['pendingKids'] ?? []);
      final acceptedKids = List<String>.from(data['kids'] ?? []);

      if (acceptedKids.contains(kidId)) {
        return 'accepted';
      } else if (pendingKids.contains(kidId)) {
        return 'pending';
      } else {
        return 'rejected';
      }
    });
  }



  Future<bool> waitForPairingResponse({
    required String parentId,
    required String kidId,
    Duration? timeout,
  }) async {
    final statusStream = watchPairingRequestStatus(
      parentId: parentId,
      kidId: kidId,
    );

    final completer = Completer<bool>();
    StreamSubscription? subscription;

    subscription = statusStream.listen((status) {
      if (status == 'accepted') {
        completer.complete(true);
        subscription?.cancel();
      } else if (status == 'rejected') {
        completer.complete(false);
        subscription?.cancel();
      }

    });


    if (timeout != null) {
      Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.complete(false);
        }
      });
    }

    return completer.future;
  }





}
