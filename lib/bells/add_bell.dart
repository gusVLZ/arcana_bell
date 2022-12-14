// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:arcana_bell/model/bell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  Provisioner? provisioner;
  String? password;

  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _wifiName;

  Timer? timer;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? configController;

  List userBells = [];

  Bell bell = Bell(null, null);

  @override
  void initState() {
    _isLoading = false;
    _passwordVisible = false;
    [Permission.location]
        .request()
        .then((value) => info.getWifiName().then((value) => setState(() {
              _wifiName = value;
            })));
    super.initState();
    info.getWifiName().then((value) => setState(() {
          _wifiName = value;
        }));
  }

  @override
  void deactivate() {
    provisioner?.stop();
    super.deactivate();
  }

  _saveBellInfo(context) async {
    String token = login!.currentUser!.user!.uid;

    try {
      await FirebaseFirestore.instance.collection('bell').doc(bell.id).set({
        "description": bell.description,
        "mac": bell.mac,
        "users": [token]
      }, SetOptions(merge: true)).then((value) async {
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

        await FirebaseMessaging.instance.subscribeToTopic("bell_${bell.id}");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurado com sucesso'),
          duration: Duration(seconds: 5),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Erro ao cadastrar campainha, verifique se o dispositivo est?? pr??ximo e em modo de configura????o',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      stderr.writeln(e.toString());
    }
  }

  _setupError() {
    configController?.close();
    setState(() {
      _isLoading = false;
    });
    provisioner?.stop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Erro ao cadastrar campainha, verifique se o dispositivo est?? pr??ximo e em modo de configura????o',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  _startSmartConfig(context) async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();
        configController = ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configurando...'),
            duration: Duration(seconds: 90),
          ),
        );
        provisioner = Provisioner.espTouch();
        try {
          provisioner?.listen((response) {
            stdout.writeln("Device ${response.bssidText} connected to WiFi!");
            bell.mac = response.bssidText.toUpperCase();
            bell.id = response.bssidText.toUpperCase().replaceAll(":", "");
            timer?.cancel();
            configController?.close();
            _saveBellInfo(context);
          });
        } catch (e) {
          _setupError();
          stderr.writeln(e);
        }

        timer = Timer(const Duration(seconds: 90), () {
          if (bell.mac == null) {
            _setupError();
          }
        });
        String? ssid = await info.getWifiName();
        String? bssid = await info.getWifiBSSID();

        if (ssid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Conecte-se ao wifi 2Ghz e Ligue a localiza????o do aparelho'),
            ),
          );

          setState(() {
            _isLoading = false;
          });
          provisioner?.stop();
        } else {
          if (ssid.startsWith('"')) {
            ssid = ssid.substring(1, (ssid.length - 1));
          }

          await provisioner?.start(ProvisioningRequest.fromStrings(
            ssid: ssid,
            bssid: bssid!,
            password: password,
          ));
        }
      } catch (e) {
        _setupError();
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _wifiName != null
                              ? Text("Conectado ao Wi-Fi: $_wifiName")
                              : Text(
                                  "N??o conectado a nenhum Wi-Fi",
                                  style: TextStyle(
                                      color: Theme.of(context).errorColor),
                                ),
                          const SizedBox(height: 20),
                          const Text(
                              "Tenha certeza de estar conectado a uma rede 2.4GHZ antes de configurar a campainha"),
                          const SizedBox(height: 20),
                          const Text(
                              "Pressione o bot??o da campainha por 5 segundos para entrar em modo de configura????o"),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.notification_add),
                              hintText: 'D?? um nome a campainha',
                              labelText: 'Nome *',
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigat??rio';
                              }
                              return null;
                            },
                            onSaved: (newValue) => bell.description = newValue,
                          ),
                          TextFormField(
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.wifi_password),
                              hintText: 'Senha de seu Wi-fi',
                              labelText: 'Senha Wi-fi*',
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  }),
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigat??rio';
                              }
                              return null;
                            },
                            onSaved: (newValue) => password = newValue,
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            onPressed: () async =>
                                await _startSmartConfig(context),
                            child: const Text('CONFIGURAR'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ));
  }
}
