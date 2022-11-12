import 'dart:io';

import 'package:arcana_bell/bells/add_bell.dart';
import 'package:arcana_bell/login/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'firebase_options.dart';
import 'loading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'home/home.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'Campainha', // title
    description:
        'Este canal é utilizado para notificar os disparos da Arcana Bell.', // description
    importance: Importance.max,
    enableLights: true,
    enableVibration: true,
    showBadge: true,
    vibrationPattern:
        Int64List.fromList([0, 500, 200, 800, 400, 1000, 800, 3000]));

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //await Firebase.initializeApp();
  stdout.writeln('Handling a background message ${message.messageId}');
  stdout.writeln(message.data);
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        "${notification.title ?? ''} from Main",
        notification.body ?? "",
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
          ),
        ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const SmartBell());
}

class SmartBell extends StatefulWidget {
  const SmartBell({super.key});

  @override
  State<SmartBell> createState() => _SmartBellState();
}

class _SmartBellState extends State<SmartBell> {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
            title: 'ArcanaBell',
            theme: ThemeData(
                splashFactory: InkSplash.splashFactory,
                highlightColor: Colors.green[400],
                elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16))),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                    backgroundColor: Colors.black,
                    elevation: 16,
                    enableFeedback: true,
                    selectedItemColor: Colors.white,
                    showUnselectedLabels: false,
                    type: BottomNavigationBarType.shifting),
                useMaterial3: true,
                colorScheme: const ColorScheme.dark()),
            home: const Loading(),
            debugShowCheckedModeBanner: false,
            routes: <String, WidgetBuilder>{
          "home": (BuildContext context) => const Home(),
          "login": (BuildContext context) => const Login(),
          "add_bell": (BuildContext context) => const AddBell(),
        }));
  }
}
