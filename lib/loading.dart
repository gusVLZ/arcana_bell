import 'package:flutter/material.dart';

import 'utils/login.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  bool? usuarioLogado;

  @override
  void initState() {
    loginStart();
    login?.listenChanges();
    super.initState();
  }

  tryLogging(BuildContext context) async {
    bool silent = (await login?.silentSignIn()) ?? false;
    usuarioLogado = silent;
    if (usuarioLogado == true) {
      Navigator.pushReplacementNamed(context, "home");
    } else if (usuarioLogado == false) {
      Navigator.pushReplacementNamed(context, "login");
    }
  }

  @override
  Widget build(BuildContext context) {
    tryLogging(context);

    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset("assets/muteBell.jpg", width: 250)),
          const CircularProgressIndicator()
        ]));
  }
}
