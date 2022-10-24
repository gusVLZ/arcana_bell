import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    clientId:
        '553240619445-9rbbsjof16v2f7mevm0bpn55tgpqtn19.apps.googleusercontent.com',
    scopes: <String>[
      'email',
    ],
  );

  GoogleSignInAccount? currentUser;

  listenChanges() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      currentUser = account;
      if (currentUser != null) {
        final GoogleSignInAuthentication? googleAuth =
            await currentUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    });
  }

  Future<bool> silentSignIn() async {
    return (await _googleSignIn.signInSilently())?.id != null;
  }

  void handleSignIn(BuildContext? context) async {
    try {
      bool user = (await _googleSignIn.signIn())?.id != null;
      if (context != null && user) {
        Navigator.pushNamed(context, "home");
      }
    } catch (error) {
      stderr.writeln(error);
    }
  }

  void handleSignOut(BuildContext? context) async {
    await _googleSignIn.disconnect();
    if (context != null) {
      Navigator.pushNamed(context, "login");
    }
  }
}

Login? login;

loginStart() {
  login = Login();
  login?.silentSignIn();
}

//Having a clear function is pretty handy
void clearLoginData() {
  login = Login();
}
