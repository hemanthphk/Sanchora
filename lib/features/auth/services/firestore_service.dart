import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  /// Checks if the user document exists in Firestore.
  Future<bool> checkUserExists(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      await userDoc.update({'updatedAt': FieldValue.serverTimestamp()});
      return true;
    }
    return false;
  }

  /// Creates a new user profile in Firestore.
  Future<void> createUserProfile({
    required User user,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    await userDoc.set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl ?? user.photoURL,
      'phoneNumber': phone,
      'premium': false,
      'createdAt': now,
      'updatedAt': now,
      'emailVerified': false, // Enforce default to false upon creation
      'settings': {},
    });
  }

  /// Marks the user's email as verified in Firestore
  Future<void> updateEmailVerified(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({
      'emailVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
