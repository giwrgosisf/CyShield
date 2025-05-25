import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class NotificationService {
  static Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function(String? token) onTokenRefresh,
  }) async {
    final messaging = FirebaseMessaging.instance;

    // request permission on iOS
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // get token
    final token = await messaging.getToken();
    debugPrint('🆔 SOS SOS SOS FCM device token: $token');
    await onTokenRefresh(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(onTokenRefresh);

    // foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showInAppNotification(message, navigatorKey);
    });

    // background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message, navigatorKey);
    });

    // launch app from terminated state message
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      _handleMessageTap(initialMsg, navigatorKey);
    }
  }

  static void _showInAppNotification(
      RemoteMessage message,
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    // final data = message.data;
    // final type = data['type'] as String?;
    final body = message.notification?.body ?? '';
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(body),
        action: SnackBarAction(
          label: 'Άνοιγμα',
          onPressed: () => _goToNotifications(navigatorKey),
        ),
      ),
    );
  }

  static void _handleMessageTap(
      RemoteMessage message,
      GlobalKey<NavigatorState> navigatorKey,
      ) {
    // final data = message.data;
    // final type = data['type'] as String?;

    _goToNotifications(navigatorKey);
  }

  static void _goToNotifications(GlobalKey<NavigatorState> navigatorKey) {
    final nav = navigatorKey.currentState!;
    //final ctx = navigatorKey.currentContext!;
    nav.popUntil((route) => route.isFirst);
    nav.pushNamed('/notifications');
  }
}
