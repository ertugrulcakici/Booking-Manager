import 'dart:developer' as dev;
import 'dart:math';

import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();

    await _handleToken();

    // FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
    //   if (initialMessage != null) {
    //     _handleMessage(initialMessage);
    //   }
    // });

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onBackgroundMessage(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    dev.log("Message: ${message.toMap()}", name: "NotificationService");

    final messageId = Random().nextInt(1000);
    final title = message.data['notification']["title"];
    final body = message.data['notification']["body"];
    final channelId = message.data['data']["channelId"];
    final channelName = message.data['data']["channelName"];

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var android = AndroidNotificationDetails(channelId, channelName);
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(messageId, title, body, platform,
        payload: message.data['data']);
  }

  Future<void> _handleToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    AuthService.instance.userModel!.updateFcmToken(fcmToken);
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      AuthService.instance.userModel!.updateFcmToken(event);
    });
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  NotificationService._();
}
