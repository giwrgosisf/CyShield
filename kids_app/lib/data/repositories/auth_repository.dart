import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User?> logInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      await _saveFcmToken(user.uid);
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _firebaseAuth.signInWithCredential(credential);
    final user = cred.user!;
    final doc = _firestore.collection('kids').doc(user.uid);
    if (!(await doc.get()).exists) {
      await doc.set({
        'name': user.displayName?.split(' ').first ?? '',
        'surname': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': user.email,
        'parents':<String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _saveFcmToken(user.uid);
    }
    return user;
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String surname,
    required DateTime birthDate,
  }) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      await user.updateDisplayName(
        [name, surname].where((s) => s.isNotEmpty == true).join(' '),
      );


      await _firestore.collection('kids').doc(user.uid).set({
        'name': name,
        'surname': surname,
        'email': email,
        'parents':<String>[],
        'birthdate': Timestamp.fromDate(birthDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _saveFcmToken(user.uid);
    }
    return user;
  }

  Future<void> logOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }


  // Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
  //   return _firestore.collection('users').doc(uid).snapshots();
  // }

  User? get currentUser => _firebaseAuth.currentUser;
  String? get currentUserUid => _firebaseAuth.currentUser?.uid;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();


  Future<void> _saveFcmToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firestore
          .collection('kids')
          .doc(uid)
          .update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }
}
