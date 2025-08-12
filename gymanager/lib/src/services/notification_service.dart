import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gymanager/src/services/api_service.dart'; // Import ApiService

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();

    if (fcmToken != null) {
      print('FCM Token: $fcmToken'); // You can keep this for debugging
      // Send the token to your server
      await ApiService.saveFcmToken(fcmToken);
    }
  }
}
