import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn());

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      await _firebaseAuth.signInWithPopup(provider);
      return;
    }

    final googleUser = await _googleSignIn!.signIn();
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    appleProvider.addScope('name');

    if (kIsWeb) {
      await _firebaseAuth.signInWithPopup(appleProvider);
      return;
    }

    await _firebaseAuth.signInWithProvider(appleProvider);
  }

  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _firebaseAuth.signOut();
  }
}
