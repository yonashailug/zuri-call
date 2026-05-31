import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => ios,
      _ => throw UnsupportedError(
          'Firebase options are only configured for iOS.',
        ),
    };
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBV_2CCdm7r09oxzAt55w6UafBkCttVM0',
    appId: '1:334471117471:ios:b6e9dffb75b1b15ce340aa',
    messagingSenderId: '334471117471',
    projectId: 'zuri-call',
    storageBucket: 'zuri-call.firebasestorage.app',
    iosBundleId: 'com.zuri.zuriCall',
  );
}
