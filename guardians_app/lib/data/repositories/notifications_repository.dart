import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  Stream<List<NotificationItem>> watchNotifications() {
    final notificationCollection = _db
        .collection('users')
        .doc(_uid)
        .collection('notifications');

    return notificationCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) {
                final data = doc.data();
                final type = data['type'] as String? ?? '';
                final seen = data['seen'] as bool? ?? false;
                final timestamp = (data['timestamp'] as Timestamp).toDate();

                switch (type) {
                  case 'new_report':
                    return ReportNotification(
                      id: doc.id,
                      reportId: data['reportId'] as String? ?? doc.id,
                      message: data['body'],
                      timestamp: timestamp,
                      seen: seen,
                    );

                  case 'guardian_request':
                    return RequestNotification(
                      id: doc.id,
                      kidId: data['kidId'] as String,
                      kidName: data['kidName'] as String,
                      timestamp: timestamp,
                      seen: seen,
                    );

                  default:
                    return ReportNotification(
                      id: doc.id,
                      reportId: doc.id,
                      message: data['body'] as String? ?? 'Άγνωστη ειδοποίηση',
                      timestamp: timestamp,
                      seen: seen,
                    );
                }
              }).toList(),
        );
  }

  Future<void> markAllSeen() async {
    final notificationsCollection = _db
        .collection('users')
        .doc(_uid)
        .collection('notifications');
    final snapshot =
        await notificationsCollection.where('seen', isEqualTo: false).get();
    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'seen': true});
    }
  }

  Future<void> markSeen(String notificationId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'seen': true});
  }

  Future<void> acceptRequest(String notificationId, String kidId) {
    final parentId = _db.collection('users').doc(_uid);
    final batch = _db.batch();

    batch.update(parentId, {
      'pendingKids': FieldValue.arrayRemove([kidId]),
      'kids': FieldValue.arrayUnion([kidId]),
    });

    batch.delete(parentId.collection('notifications').doc(notificationId));

    return batch.commit();
  }

  Future<void> rejectRequest(String notificationId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
