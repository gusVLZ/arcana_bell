import 'dart:io';

import 'package:arcana_bell/bells/bells.dart';
import 'package:arcana_bell/history/history.dart';
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
  String? messageId;
  @override
  void initState() {
    setupNotification();

    checkForInitialMessage();

    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  void setupNotification() async {
    Future<void> firebaseMessagingForegroundHandler(
        RemoteMessage message) async {
      stdout.writeln('Handling a background message ${message.messageId}');
      stdout.writeln(message.data);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null &&
          android != null &&
          messageId != message.messageId) {
        setState(() {
          messageId = message.messageId;
        });
        showSimpleNotification(
            Text(
              notification.title ?? '',
            ),
            background: Colors.green,
            autoDismiss: false,
            duration: const Duration(seconds: 20),
            slideDismissDirection: DismissDirection.up,
            contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            subtitle: Text(
              notification.body ?? "",
            ));
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
  final _pageViewController = PageController();
  final List<Widget> _screens = [const Bells(), const History()];

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
        margin: const EdgeInsets.all(10),
        child: PageView(
          allowImplicitScrolling: true,
          controller: _pageViewController,
          children: _screens,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: "Dispositivos"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "Histórico"),
          ],
          onTap: (index) {
            _pageViewController.animateToPage(index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.bounceOut);
          }),
    );
  }
}
