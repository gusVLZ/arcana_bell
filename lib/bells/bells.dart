import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../model/bell.dart';
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

  getUserBells() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(token)
          .get()
          .then((value) async {
        if (value.exists) {
          userBells = value.get("bells");

          for (var element in userBells) {
            FirebaseMessaging.instance.subscribeToTopic("bell_$element");
          }

          bells = [];
          if (userBells.isNotEmpty) {
            QuerySnapshot qShot = (await FirebaseFirestore.instance
                .collection('bell')
                .where("__name__", whereIn: userBells)
                .get());

            for (var doc in qShot.docs) {
              bells.add(Bell(doc.id, doc.get("description")));
            }
          }
        } else {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(token)
              .set({"bells": []});
          bells = [];
        }
      });

      setState(() {
        userBells = userBells;
        bells = bells;
      });
    } catch (e) {
      stderr.writeln(e.toString());
    }
  }

  @override
  void initState() {
    getToken();
    getUserBells();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListView.builder(
                itemCount: bells.length,
                shrinkWrap: true,
                clipBehavior: Clip.hardEdge,
                itemBuilder: (context, index) => ListTile(
                  title: Text(bells[index].description ?? "Sem descrição"),
                  trailing: IconButton(
                      onPressed: () async {
                        try {
                          await FirebaseMessaging.instance
                              .unsubscribeFromTopic("bell_${bells[index].id}");
                          setState(() {
                            userBells.remove(bells[index].id);
                          });
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(token)
                              .set({'bells': userBells},
                                  SetOptions(merge: false));
                        } catch (e) {
                          stderr.writeln(e.toString());
                        }
                        getUserBells();
                      },
                      icon: const Icon(Icons.delete)),
                ),
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, "add_bell")
                        .then((value) async {
                      await getUserBells();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("NOVA CAMPAINHA")),
            ]));
  }
}
