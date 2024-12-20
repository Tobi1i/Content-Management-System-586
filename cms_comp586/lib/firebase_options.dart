// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAsHGoBlkKdorbDXqTzCGfsEImZDSRSnOw',
    appId: '1:605888775209:web:59979e60e30c8e2bc98838',
    messagingSenderId: '605888775209',
    projectId: 'compwebcms',
    authDomain: 'compwebcms.firebaseapp.com',
    storageBucket: 'compwebcms.appspot.com',
    measurementId: 'G-QDG73FYHXJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4Bhpt2WHpNClSlFhIbFqOdPiv2pXc8jI',
    appId: '1:605888775209:android:db5236c639cd206cc98838',
    messagingSenderId: '605888775209',
    projectId: 'compwebcms',
    storageBucket: 'compwebcms.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBqglxRJ7uw4RA0Wdn1KIse_Lvk4cBOe-g',
    appId: '1:605888775209:ios:03ef4871364c13f1c98838',
    messagingSenderId: '605888775209',
    projectId: 'compwebcms',
    storageBucket: 'compwebcms.appspot.com',
    iosBundleId: 'com.example.cmsComp586',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBqglxRJ7uw4RA0Wdn1KIse_Lvk4cBOe-g',
    appId: '1:605888775209:ios:03ef4871364c13f1c98838',
    messagingSenderId: '605888775209',
    projectId: 'compwebcms',
    storageBucket: 'compwebcms.appspot.com',
    iosBundleId: 'com.example.cmsComp586',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAsHGoBlkKdorbDXqTzCGfsEImZDSRSnOw',
    appId: '1:605888775209:web:b4e8aadd28610f9ec98838',
    messagingSenderId: '605888775209',
    projectId: 'compwebcms',
    authDomain: 'compwebcms.firebaseapp.com',
    storageBucket: 'compwebcms.appspot.com',
    measurementId: 'G-45K7KZ55F0',
  );
}
