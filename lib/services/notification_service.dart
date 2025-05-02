//notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fm.requestPermission();
    FirebaseMessaging.onMessage.listen((msg) {
      // Aqui você pode mostrar uma local notification se quiser
      print('Nova notificação: ${msg.notification?.title}');
    });
  }

  Future<String?> getToken() async {
    return await _fm.getToken();
  }
}
