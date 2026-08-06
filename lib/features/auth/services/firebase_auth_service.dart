import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseAuthService instance = FirebaseAuthService._();
  FirebaseAuthService._();

  String? _verificationId;
  int? _resendToken;

  /// Starts the phone authentication process by verifying the phone number.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: _resendToken,
    );
  }

  /// Verifies the OTP code entered by the user.
  Future<UserCredential> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID is null. Please request OTP first.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  /// Checks if the user document exists in Firestore.
  Future<bool> checkUserExists(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (snapshot.exists) {
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    }
    return false;
  }

  /// Creates a new user profile in Firestore.
  Future<void> createUserProfile({
    required User user,
    required String name,
    required String email,
    required String phone,
  }) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    await userDoc.set({
      'uid': user.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': null,
      'joinedDate': now,
      'lastLogin': now,
      'isPremium': false,
      'activeSubscriptions': 0,
      'totalSpent': 0.0,
      'totalSaved': 0.0,
    });
  }

  /// Optional: Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
