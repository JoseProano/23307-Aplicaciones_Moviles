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
    apiKey: 'AIzaSyDZsYE_cFgv3RqwP6G7iPPxngmGSOHpHbs',
    appId: '1:279917091784:web:934de1fdc7a1fbac92fefd',
    messagingSenderId: '279917091784',
    projectId: 'prueba-p3-2b85a',
    authDomain: 'prueba-p3-2b85a.firebaseapp.com',
    storageBucket: 'prueba-p3-2b85a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBEPc1CqJBypBgPWm2cApYPFfT9aFffFg',
    appId: '1:279917091784:android:9d7487e5b958895692fefd',
    messagingSenderId: '279917091784',
    projectId: 'prueba-p3-2b85a',
    storageBucket: 'prueba-p3-2b85a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB5alUW7SsEZzqSyKvqdWGNbrYsClt82EQ',
    appId: '1:279917091784:ios:accf088810f5bc8192fefd',
    messagingSenderId: '279917091784',
    projectId: 'prueba-p3-2b85a',
    storageBucket: 'prueba-p3-2b85a.firebasestorage.app',
    iosBundleId: 'com.example.pruebaP3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB5alUW7SsEZzqSyKvqdWGNbrYsClt82EQ',
    appId: '1:279917091784:ios:accf088810f5bc8192fefd',
    messagingSenderId: '279917091784',
    projectId: 'prueba-p3-2b85a',
    storageBucket: 'prueba-p3-2b85a.firebasestorage.app',
    iosBundleId: 'com.example.pruebaP3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZsYE_cFgv3RqwP6G7iPPxngmGSOHpHbs',
    appId: '1:279917091784:web:296982f9ff6fca5c92fefd',
    messagingSenderId: '279917091784',
    projectId: 'prueba-p3-2b85a',
    authDomain: 'prueba-p3-2b85a.firebaseapp.com',
    storageBucket: 'prueba-p3-2b85a.firebasestorage.app',
  );
}
