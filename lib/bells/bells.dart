import 'package:flutter/material.dart';

class Bells extends StatefulWidget {
  const Bells({Key? key}) : super(key: key);

  @override
  _BellsState createState() => _BellsState();
}

class _BellsState extends State<Bells> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Usuário logado!",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }
}
