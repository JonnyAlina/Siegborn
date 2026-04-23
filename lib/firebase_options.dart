import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    if (Platform.isMacOS) {
      return macos;
    }
    if (Platform.isWindows) {
      return windows;
    }
    if (Platform.isLinux) {
      return linux;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBfcLCa9RnVjklmR1E-G5uqrHBZQOhNrFU',
    appId: '1:1085877847479:web:98ee48d038284f0bf15432',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    authDomain: 'siegeborn-app-2026.firebaseapp.com',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
    measurementId: 'G-TT2GW87BSN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0mW_u4Yb3jBc9KxL4pQ8nR2sT6vU7wX8Y',
    appId: '1:1085877847479:android:abcdef1234567890',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0mW_u4Yb3jBc9KxL4pQ8nR2sT6vU7wX8Y',
    appId: '1:1085877847479:ios:abcdef1234567890',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0mW_u4Yb3jBc9KxL4pQ8nR2sT6vU7wX8Y',
    appId: '1:1085877847479:ios:abcdef1234567890',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBfcLCa9RnVjklmR1E-G5uqrHBZQOhNrFU',
    appId: '1:1085877847479:windows:abcdef1234567890',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBfcLCa9RnVjklmR1E-G5uqrHBZQOhNrFU',
    appId: '1:1085877847479:web:abcdef1234567890',
    messagingSenderId: '1085877847479',
    projectId: 'siegeborn-app-2026',
    storageBucket: 'siegeborn-app-2026.firebasestorage.app',
  );
}
