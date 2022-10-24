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

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("HomeScreenLogged"),
      ElevatedButton.icon(
          onPressed: () => login?.handleSignOut(context),
          icon: const Icon(Icons.logout),
          label: const Text("Logout"))
    ]));
  }
}
