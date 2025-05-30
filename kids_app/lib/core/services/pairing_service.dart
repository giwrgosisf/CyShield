// pairing_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kids_app/core/services/backend_services.dart';

import '../../data/models/kid_profile.dart';
import '../../data/models/pairing_request.dart';

class PairingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BackendServices server = BackendServices(
    baseUrl: 'http://192.168.1.79',
  );

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




  Future<void> addParentToKid({required String parentId, String? kidId}) async {
    final childDoc = _db.collection('kids').doc(kidId ?? _uid);
    await childDoc.update({
      'parents': FieldValue.arrayUnion([parentId]),
    });

  }

  Future<bool> hasThisParentAlready({
    required String parentId,
    String? kidId,
  }) async {
    final docRef = _db.collection('kids').doc(kidId ?? _uid);
    final snap = await docRef.get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    final parents = List<String>.from(data['parents'] ?? <String>[]);
    return parents.contains(parentId);
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
    required String parentID,
    required String kidName,
  }) async {
    server.notifyParent(
      userId: parentID,
      title: "New pairing request from $kidName",
      body: "$kidName wants to add you as a guardian!",
    );
  }



  Stream<String> watchPairingRequestStatus({
    required String parentId,
    required String kidId,
  }) {
    return _db.collection('users').doc(parentId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return 'rejected';
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final pendingKids = List<String>.from(data['pendingKids'] ?? []);
      final acceptedKids = List<String>.from(data['kids'] ?? []);


        if (acceptedKids.contains(kidId)) {
          addParentToKid(parentId: parentId);
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
