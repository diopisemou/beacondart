import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:beacondart/beacondart.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dart_bs58check/dart_bs58check.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool isInvalidDappError = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await Beacondart.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    Beacondart.onInit();
    Beacondart.getOperationStreamReceiver()?.listen((barcode) {
      /// data to be used in the dapp

      debugPrint(barcode);
    });
  }

  Future<List<dynamic>> readDAppFromQrCode() async {
    dynamic qrcodeScanRes = '';
    bool status = false;
    try {
      // qrcodeScanRes = FlutterBarcodeScanner.getBarcodeStreamReceiver(
      //   "#4a5aed",
      //   "Cancel",
      //   true,
      //   ScanMode.QR,
      // );
      qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#4a5aed",
        "Cancel",
        true,
        ScanMode.QR,
      );
      status = true;
    } on PlatformException {
      qrcodeScanRes = "Error lors du scan";
    }
    return [status, qrcodeScanRes];
  }

  Future<List<dynamic>> readDAppFromQrCodeV2() async {
    dynamic qrcodeScanRes = '';
    bool status = false;
    try {
      Beacondart.addDApp();
      status = true;
    } on PlatformException {
      qrcodeScanRes = "Error lors du scan";
    }
    return [status, qrcodeScanRes];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),

              ///Scan Icon
              GestureDetector(
                onTap: () async {
                  //Scan QrCode
                  // List<dynamic> array = await readDAppFromQrCode();
                  List<dynamic> array = await readDAppFromQrCodeV2();
                  if (array[1] == '-1' || array[0] == false) {
                    setState(() {
                      isInvalidDappError = true;
                    });
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
