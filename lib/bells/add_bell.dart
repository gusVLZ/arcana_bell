// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:arcana_bell/model/bell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/login.dart';

class AddBell extends StatefulWidget {
  const AddBell({Key? key}) : super(key: key);

  @override
  AddBellState createState() => AddBellState();
}

class AddBellState extends State<AddBell> {
  final _formKey = GlobalKey<FormState>();
  final info = NetworkInfo();
  final provisioner = Provisioner.espTouch();
  String? password;

  List userBells = [];

  Bell bell = Bell(null, null);

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    provisioner.stop();
    super.deactivate();
  }

  _saveBellInfo() async {
    String token = login!.currentUser!.user!.uid;

    await FirebaseFirestore.instance.collection('bell').add({
      "description": bell.description,
      "mac": bell.mac,
      "users": [token]
    }).then((value) async {
      bell.id = value.id;

      await FirebaseFirestore.instance
          .collection('user')
          .doc(token)
          .get()
          .then((value) => userBells = value.get("bells"));

      userBells.add(bell.id);

      await FirebaseFirestore.instance
          .collection('user')
          .doc(token)
          .set({'bells': userBells}, SetOptions(merge: true));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurado com sucesso'),
        duration: Duration(seconds: 20),
      ),
    );

    Navigator.of(context).pushNamed("home");
  }

  _startSmartConfig() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<Permission, PermissionStatus> statuses =
            await [Permission.location].request();
        _formKey.currentState!.save();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurando...'),
            duration: Duration(seconds: 20),
          ),
        );

        var timer = Timer(
            const Duration(seconds: 20),
            () => {
                  if (bell.mac == null)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Erro ao cadastrar campainha, verifique se o dispositivo está próximo e em modo de configuração',
                              style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ),
                      )
                    }
                });

        timer.cancel();
      } catch (e) {
        stderr.writeln(e);
      }
      try {
        String? ssid = await info.getWifiName();
        String? bssid = await info.getWifiBSSID();

        if (ssid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Conecte-se ao wifi 2Ghz e Ligue a localização do aparelho'),
            ),
          );
        } else {
          if (ssid.startsWith('"')) {
            ssid = ssid.substring(1, (ssid.length - 1));
          }
          provisioner.listen((response) {
            stdout.writeln("Device ${response.bssidText} connected to WiFi!");
            bell.mac = response.bssidText;
            _saveBellInfo();
          });
          await provisioner.start(ProvisioningRequest.fromStrings(
            ssid: ssid,
            bssid: bssid!,
            password: password,
          ));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erro ao cadastrar campainha, verifique se a senha do wifi informada está correta',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        stderr.writeln(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Adicionar Campainha'),
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description),
                    hintText: 'Dê um nome a campainha',
                    labelText: 'Nome *',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                  onSaved: (newValue) => bell.description = newValue,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.description),
                    hintText: 'Qual a senha que usa para se conectar no wi-fi',
                    labelText: 'Senha *',
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  },
                  onSaved: (newValue) => password = newValue,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async => await _startSmartConfig(),
                  child: const Text('CONFIGURAR'),
                ),
              ],
            ),
          ),
        ));
  }
}
