// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'pages/login_page.dart';
import 'services/session_guard.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BACKGROUND NOTIFICATION: ${message.messageId}');
}

Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(alert: true, badge: true, sound: true);

  debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

  final token = await messaging.getToken();
  debugPrint('🔥 FCM TOKEN: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('🔔 Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('🔔 Notification clicked');
    debugPrint('Data: ${message.data}');
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await setupFirebaseMessaging();
    } else {
      debugPrint('🌐 Running on Web: Firebase Messaging skipped');
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Mobile Agent',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0F3D2E)), useMaterial3: true),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SessionGuard(navigatorKey: appNavigatorKey, child: child ?? const SizedBox.shrink());
      },
    );
  }
}
