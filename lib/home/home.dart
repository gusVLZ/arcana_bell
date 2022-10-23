import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  clientId:
      '553240619445-9rbbsjof16v2f7mevm0bpn55tgpqtn19.apps.googleusercontent.com',
  scopes: <String>[
    'email',
  ],
);

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        final GoogleSignInAuthentication? googleAuth =
            await _currentUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    });
    _googleSignIn.signInSilently();
  }

  void _handleSignIn(BuildContext context) {
    try {
      _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      Navigator.of(context).pushNamed("bells");
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (_currentUser != null)
            IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: _handleSignOut),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset("assets/muteBell.jpg", width: 200)),
          Container(
            margin: const EdgeInsets.all(20),
            child: Text(
              'Acesse para cadastrar e receber notificações de suas campainhas',
              style: Theme.of(context).textTheme.headline5,
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleSignIn(context),
            child: const Text('ENTRAR'),
          ),
        ],
      )),
    );
  }
}
