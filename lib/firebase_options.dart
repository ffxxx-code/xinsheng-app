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
    apiKey: 'AIzaSyCtci-Q1x-jytAXZSt96dyBq7L5uf9oBkY',
    appId: '1:504967530478:web:placeholder',
    messagingSenderId: '504967530478',
    projectId: 'xinsheng-app',
    authDomain: 'xinsheng-app.firebaseapp.com',
    storageBucket: 'xinsheng-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtci-Q1x-jytAXZSt96dyBq7L5uf9oBkY',
    appId: '1:504967530478:android:6f3ac4da62392b276b70ff',
    messagingSenderId: '504967530478',
    projectId: 'xinsheng-app',
    storageBucket: 'xinsheng-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAfVYYl8vMZlm_4dNF5IvSixn5mAtmvclI',
    appId: '1:504967530478:ios:a14fc0f1816ee0816b70ff',
    messagingSenderId: '504967530478',
    projectId: 'xinsheng-app',
    storageBucket: 'xinsheng-app.firebasestorage.app',
    iosBundleId: 'com.xinsheng.xinsheng',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAfVYYl8vMZlm_4dNF5IvSixn5mAtmvclI',
    appId: '1:504967530478:ios:a14fc0f1816ee0816b70ff',
    messagingSenderId: '504967530478',
    projectId: 'xinsheng-app',
    storageBucket: 'xinsheng-app.firebasestorage.app',
    iosBundleId: 'com.xinsheng.xinsheng',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCtci-Q1x-jytAXZSt96dyBq7L5uf9oBkY',
    appId: '1:504967530478:web:placeholder',
    messagingSenderId: '504967530478',
    projectId: 'xinsheng-app',
    authDomain: 'xinsheng-app.firebaseapp.com',
    storageBucket: 'xinsheng-app.firebasestorage.app',
  );
}
