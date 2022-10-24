import 'package:arcana_bell/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'loading.dart';
import 'bells/bells.dart';
import 'home/home.dart';

void main() {
  runApp(const SmartBell());
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class SmartBell extends StatefulWidget {
  const SmartBell({super.key});

  @override
  State<SmartBell> createState() => _SmartBellState();
}

class _SmartBellState extends State<SmartBell> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ArcanaBell',
        theme: ThemeData(
            useMaterial3: true, colorScheme: const ColorScheme.dark()),
        home: const Loading(),
        routes: <String, WidgetBuilder>{
          "home": (BuildContext context) => const Home(),
          "login": (BuildContext context) => const Login(),
          "bells": (BuildContext context) => const Bells(),
        });
  }
}
