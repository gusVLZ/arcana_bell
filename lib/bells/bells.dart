import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../utils/login.dart';

class Bells extends StatefulWidget {
  const Bells({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  BellsState createState() => BellsState();
}

class BellsState extends State<Bells> {
  String? token;
  List userBells = [];
  List<Bell> bells = [];
  getToken() async {
    //token = await FirebaseMessaging.instance.getToken();
    token = login!.currentUser!.user!.uid;
    setState(() {
      token = token;
    });
    stdout.writeln(token);
  }

  getBells() async {
    try {
      QuerySnapshot qShot = (await FirebaseFirestore.instance
          .collection('bell')
          .where("users", arrayContains: token)
          .get());

      bells = [];

      for (var doc in qShot.docs) {
        bells.add(Bell(doc.id, doc.get("description")));
      }

      setState(() {
        bells = bells;
      });
    } catch (e) {
      stderr.writeln(e.toString());
    }
  }

  getUserBells() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(token)
          .get()
          .then((value) => userBells = value.get("bells"));

      setState(() {
        userBells = userBells;
      });
    } catch (e) {
      stderr.writeln(e.toString());
    }
  }

  @override
  void initState() {
    getToken();
    getUserBells();
    getBells();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ListView.builder(
        itemCount: bells.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => ListTile(
          title: Text(bells[index].description),
          trailing: userBells.contains(bells[index].id)
              ? ElevatedButton(
                  onPressed: () async {
                    await FirebaseMessaging.instance
                        .unsubscribeFromTopic("bell_${bells[index].id}");
                    setState(() {
                      userBells.remove(bells[index].id);
                    });
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(token)
                        .set({'bells': userBells}, SetOptions(merge: false));
                  },
                  child: const Text('Ignorar'),
                )
              : ElevatedButton(
                  onPressed: () async {
                    await FirebaseMessaging.instance
                        .subscribeToTopic("bell_${bells[index].id}");
                    setState(() {
                      userBells.add(bells[index].id);
                    });
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(token)
                        .set({'bells': userBells}, SetOptions(merge: false));
                  },
                  child: const Text('Receber')),
        ),
      ),
      ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, "add_bell"),
          icon: const Icon(Icons.add),
          label: const Text("NOVA CAMPAINHA"))
    ]);
  }
}

class Bell {
  Bell(this.id, this.description);
  String id;
  String description;
}
