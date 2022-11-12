import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/history.dart' as model;
import 'package:intl/intl.dart';

import '../utils/login.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> {
  String? token;
  Timer? timer;
  List<model.History> history = [];

  getHistory() async {
    try {
      token = login!.currentUser!.user!.uid;
      QuerySnapshot qShot = (await FirebaseFirestore.instance
          .collection('bell_history')
          .where("users", arrayContains: token)
          .orderBy("datetime", descending: true)
          .limit(100)
          .get());
      history = [];
      for (var doc in qShot.docs) {
        history.add(model.History(doc.id, doc.get("bell"), doc.get("title"),
            doc.get("datetime").toDate()));
      }

      setState(() {
        history = history;
      });
    } catch (e) {
      stderr.writeln(e.toString());
    }
  }

  @override
  void initState() {
    getHistory();
    setState(() {
      timer = Timer.periodic(const Duration(seconds: 30), (timer) {
        getHistory();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: history.length,
      clipBehavior: Clip.hardEdge,
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          history[index].title ?? "Sem descrição",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          history[index].datetime != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(history[index].datetime!)
              : "Sem data",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        leading: const Icon(Icons.notifications),
        trailing: IconButton(
            onPressed: () async {
              try {
                FirebaseFirestore.instance
                    .collection('bell_history')
                    .doc(history[index].id)
                    .delete();
                setState(() {
                  history.remove(history[index]);
                });
              } catch (e) {
                stderr.writeln(e.toString());
              }
            },
            icon: const Icon(Icons.close)),
      ),
    );
  }
}
