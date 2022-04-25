import 'package:flutter/material.dart';
import 'dart:async';

import 'package:beacondart/beacondart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    BeaconWalletClient bmw = BeaconWalletClient();
    await bmw.init(
      'Ejara',
      '9ae0875d510904b0b15d251d8def1f5f3353e9799841c0ed6d7ac718f04459a0',
      'tz1SkbBZg15BXPRkYCrSzhY6rq4tKGtpUSWv',
    );
    // Map<String, String> dApp = {
    //   "id": "c9393d90-b315-d3b8-6442-890813dfc1b9",
    //   "name": "Beacon Docs",
    //   "publicKey":
    //       "015270460ae9144fe178e7ee00a3ec85b3d15e9b1d80fa907b3eb0ac4653fc27",
    //   "relayServer": "beacon-node-1.hope-3.papers.tech",
    //   "version": "2"
    // };
    // await bmw.addPeer(dApp);
    // await bmw.getPeers((response) {
    //   print(response);
    // });

    // await bmw.onBeaconRequest((response) {
    //   print(response);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const Center(
          child: Text('Program is running ...'),
        ),
      ),
    );
  }
}
