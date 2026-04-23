import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthFlowException implements Exception {
  const AuthFlowException({
    required this.code,
    required this.userMessage,
  });

  final String code;
  final String userMessage;
}

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

  bool get isAppleSignInAvailable =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> signInWithGoogle() async {
    Future<void> signInWithCredential(GoogleAuthProvider provider) async {
      try {
        await _firebaseAuth.signInWithPopup(provider);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'popup-closed-by-user') {
          return;
        }

        throw const AuthFlowException(
          code: 'google-sign-in-failed',
          userMessage: 'Google Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
        );
      }
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      await signInWithCredential(provider);
      return;
    }

    try {
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
    } on FirebaseAuthException {
      throw const AuthFlowException(
        code: 'google-sign-in-failed',
        userMessage: 'Google Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      );
    } catch (_) {
      throw const AuthFlowException(
        code: 'google-sign-in-failed',
        userMessage: 'Google Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      );
    }
  }

  Future<void> signInWithApple() async {
    if (!isAppleSignInAvailable) {
      throw UnsupportedError('Apple Login ist nur auf iOS, macOS und Web verfuegbar.');
    }

    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');
    appleProvider.addScope('name');

    if (kIsWeb) {
      try {
        await _firebaseAuth.signInWithPopup(appleProvider);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'popup-closed-by-user') {
          return;
        }

        throw const AuthFlowException(
          code: 'apple-sign-in-failed',
          userMessage: 'Apple Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
        );
      }
      return;
    }

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256OfString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null) {
        throw const AuthFlowException(
          code: 'missing-apple-identity-token',
          userMessage: 'Apple Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
        );
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      await _firebaseAuth.signInWithCredential(oauthCredential);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return;
      }

      throw const AuthFlowException(
        code: 'apple-sign-in-failed',
        userMessage: 'Apple Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      );
    } on FirebaseAuthException {
      throw const AuthFlowException(
        code: 'apple-sign-in-failed',
        userMessage: 'Apple Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      );
    } catch (_) {
      throw const AuthFlowException(
        code: 'apple-sign-in-failed',
        userMessage: 'Apple Anmeldung fehlgeschlagen. Bitte erneut versuchen.',
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _firebaseAuth.signOut();
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
