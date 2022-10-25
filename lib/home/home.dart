import 'package:arcana_bell/bells/bells.dart';
import 'package:flutter/material.dart';

import '../utils/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;
  final List<Widget> _screens = [
    const Bells(title: "Dispositivos"),
    const Bells(title: "Histórico"),
    const Bells(title: "Perfil")
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Dispositivos"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "Histórico"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          ],
          onTap: onTabTapped),
    );
  }
}
