import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  bool get isLoggedIn => user != null;

  Future<void> updateLocalAvatar(String imagePath) async {
  final currentUser = _auth.currentUser;

  if (currentUser == null) return;

  await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
    'localAvatar': imagePath,
    'name': currentUser.displayName,
    'email': currentUser.email,
    'photoURL': currentUser.photoURL,
  }, SetOptions(merge: true));

  notifyListeners();
}

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      notifyListeners();
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    notifyListeners();
  }
}