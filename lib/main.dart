import 'bells/bells.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ArcanaBell',
        theme: ThemeData(
            useMaterial3: true, colorScheme: const ColorScheme.dark()),
        home: const MyHomePage(title: 'Smart Bell'),
        routes: <String, WidgetBuilder>{
          "bells": (BuildContext context) => const Bells(),
        });
  }
}
