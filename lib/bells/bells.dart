import 'package:flutter/material.dart';

import '../utils/login.dart';

class Bells extends StatefulWidget {
  const Bells({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _BellsState createState() => _BellsState();
}

class _BellsState extends State<Bells> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "${widget.title} de ${login!.currentUser!.displayName!}",
        style: Theme.of(context).textTheme.displaySmall,
        textAlign: TextAlign.center,
      ),
    );
  }
}
