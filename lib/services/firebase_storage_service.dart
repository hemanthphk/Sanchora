import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static final FirebaseStorageService instance = FirebaseStorageService._();
  FirebaseStorageService._();

  /// Uploads a profile image for the user and returns the download URL
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    
    final uploadTask = await ref.putFile(
      imageFile, 
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }
}
