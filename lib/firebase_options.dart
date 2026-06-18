// File placeholder.
// Setelah Firebase project dibuat, jalankan:
// flutterfire configure --platforms=android
// File ini akan ditimpa otomatis oleh FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform belum dikonfigurasi. Jalankan flutterfire configure.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXIO9cOqLjtPtukmREUpvTh0WFekqWnLU',
    appId: '1:52018188086:android:f4f61f7a01cc0df028ad97',
    messagingSenderId: '52018188086',
    projectId: 'weddingken-app',
    storageBucket: 'weddingken-app.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7Pgnq9Nxqc4rotK0oIt8pSYMJjWIWdY8',
    appId: '1:52018188086:web:d565d8d82d4dcabd28ad97',
    messagingSenderId: '52018188086',
    projectId: 'weddingken-app',
    authDomain: 'weddingken-app.firebaseapp.com',
    storageBucket: 'weddingken-app.firebasestorage.app',
    measurementId: 'G-MKWW6YFBJ9',
  );

}