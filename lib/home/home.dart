import 'package:arcana_bell/bells/bells.dart';
import 'package:arcana_bell/history/history.dart';
import 'package:arcana_bell/profile/profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

import '../main.dart';
import '../utils/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final FirebaseMessaging _messaging;

  @override
  void initState() {
    setupNotification();

    checkForInitialMessage();

    super.initState();
  }

  void setupNotification() async {
    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showSimpleNotification(Text(notification.title ?? "Nova notificação"),
            background: Theme.of(context).dialogBackgroundColor,
            autoDismiss: false,
            duration: const Duration(minutes: 5),
            slideDismissDirection: DismissDirection.up,
            subtitle: Text(notification.body ?? ""));
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
  }

  checkForInitialMessage() async {
    //await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      setState(() {});
    }
  }

  int _currentIndex = 0;
  final List<Widget> _screens = [
    const Bells(),
    const History(),
    const Profile()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Bell"),
        actions: [
          IconButton(
              onPressed: () => login!.handleSignOut(context),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Container(
          margin: const EdgeInsets.fromLTRB(5, 20, 5, 20),
          child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: "Dispositivos"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "Histórico"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          ],
          onTap: onTabTapped),
    );
  }
}
