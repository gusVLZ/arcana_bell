// ignore_for_file: use_build_context_synchronously

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

  GoogleSignInAccount? currentUserGoogle;
  UserCredential? currentUser;

  listenChanges() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      currentUserGoogle = account;
      if (currentUserGoogle != null) {
        final GoogleSignInAuthentication? googleAuth =
            await currentUserGoogle?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        currentUser =
            await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        currentUser = null;
      }
    });
  }

  Future<bool> silentSignIn() async {
    currentUserGoogle = await _googleSignIn.signInSilently();
    if (currentUserGoogle == null) {
      return false;
    }
    final GoogleSignInAuthentication? googleAuth =
        await currentUserGoogle?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    currentUser = await FirebaseAuth.instance.signInWithCredential(credential);

    return currentUser?.user?.uid != null;
  }

  void handleSignIn(BuildContext? context) async {
    try {
      currentUserGoogle = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await currentUserGoogle?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      currentUser =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (context != null && currentUser?.user != null) {
        Navigator.pushReplacementNamed(context, "home");
      }
    } catch (error, s) {
      stderr.writeln(error);
      stderr.writeln(s);
    }
  }

  void handleSignOut(BuildContext? context) async {
    await _googleSignIn.disconnect();
    currentUser = null;
    if (context != null) {
      Navigator.pushReplacementNamed(context, "login");
    }
  }
}

Login? login;

loginStart() {
  login = Login();
  //login?.silentSignIn();
}

//Having a clear function is pretty handy
void clearLoginData() {
  login = Login();
}
