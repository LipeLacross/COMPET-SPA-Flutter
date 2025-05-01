// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (identical(0, 0)) {
      // Exemplo simples: sempre Android
      return android;
    }
    throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY',
    appId: 'SUA_APP_ID',
    messagingSenderId: 'SEU_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_BUCKET.appspot.com',
  );

// Se quiser iOS:
// static const FirebaseOptions ios = FirebaseOptions(
//   apiKey: 'IOS_API_KEY',
//   appId: 'IOS_APP_ID',
//   messagingSenderId: 'IOS_SENDER_ID',
//   projectId: 'SEU_PROJECT_ID',
//   storageBucket: 'SEU_BUCKET.appspot.com',
// );
}
