// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS. '
              'Add the iOS app in Firebase Console and update this file.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ANDROID — values pulled from
  // android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkVk2Hvu8kYA5jvQ1V36Qv5H5_we_2fQo',
    appId: '1:265985634846:android:5366d3dab34189868db40f',
    messagingSenderId: '265985634846',
    projectId: 'laza-ecommerce-aad48',
    storageBucket: 'laza-ecommerce-aad48.firebasestorage.app',
  );
}