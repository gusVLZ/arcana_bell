import 'package:flutter/material.dart';

import 'utils/login.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool? UsuarioLogado;

  @override
  void initState() {
    super.initState();
    loginStart();
    login?.listenChanges();
  }

  tryLogging(BuildContext context) async {
    bool silent = (await login?.silentSignIn()) ?? false;
    UsuarioLogado = silent;
    if (UsuarioLogado == true) {
      Navigator.pushNamed(context, "home");
    } else if (UsuarioLogado == false) {
      Navigator.pushNamed(context, "login");
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
          CircularProgressIndicator()
        ]));
  }
}
