import 'dart:io';

import 'package:arcana_bell/bells/bells.dart';
import 'package:arcana_bell/history/history.dart';
import 'package:arcana_bell/profile/profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

import '../utils/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    setupNotification();

    checkForInitialMessage();

    super.initState();
  }

  void setupNotification() async {
    /*var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);*/

    //flutterLocalNotificationsPlugin.initialize(initializationSettings);

    Future<void> firebaseMessagingForegroundHandler(
        RemoteMessage message) async {
      //await Firebase.initializeApp();
      stdout.writeln('Handling a background message ${message.messageId}');
      stdout.writeln(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showSimpleNotification(Text("${notification.title ?? ''} from Simple"),
            background: Theme.of(context).dialogBackgroundColor,
            autoDismiss: false,
            duration: const Duration(minutes: 5),
            slideDismissDirection: DismissDirection.up,
            contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            subtitle: Text(notification.body ?? ""));
      }
    }

    FirebaseMessaging.onMessage.listen(firebaseMessagingForegroundHandler);
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
