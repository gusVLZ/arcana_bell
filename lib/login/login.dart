import 'package:flutter/material.dart';

import '../utils/login.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Arcana Bell"),
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
              onPressed: () => login?.handleSignIn(context),
              child: const Text('ENTRAR'),
            ),
          ],
        )));
  }
}
