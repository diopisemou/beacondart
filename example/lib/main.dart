import 'dart:convert';
import 'package:beacondart_example/permission.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:beacondart/beacondart.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:dart_bs58check/dart_bs58check.dart';

void main() {
  runZonedGuarded(() async {
    runApp(MaterialApp(
        title: 'Example App',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const MyApp()));
  }, (e, s) {
    // debugPrint("Flutter Error", error: Exception(e), stackTrace: s);
    debugPrint("Flutter Error ${e.toString()}");
  });
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
    initPlatformState(context);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(BuildContext context) async {
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

      var requestMap = json.decode(barcode);
      //debugPrint('barcode: ${requestMap.runtimeType}');
      //debugPrint("barcode-type: ${requestMap['type']}");
      if (requestMap['type'] == "tezos_permission_request") {
        // Navigator.of(context).push(
        goToPermission(requestMap);
      }
    });
  }

  void goToPermission(dynamic requestMap) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PermissionPage(
          dappAddress: Beacondart.getDappAddress() ?? '',
          dappImageUrl: Beacondart.getDappImageUrl() ?? '',
          dappName: Beacondart.getDappName() ?? '',
          dappId: Beacondart.getDappName() ?? '',
          dappBlockChain: requestMap['appMetadata']['blockchainIdentifier'],
          dappNetwork: requestMap['network']['type'],
          dappScope:
              requestMap['scopes'].fold('initialValue', (previousValue, element) => previousValue + ' ' + element),
        ),
      ),
    );
  }

  Future<List<dynamic>> readDAppFromQrCodeV2() async {
    dynamic qrcodeScanRes = '';
    bool status = false;
    try {
      qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#4a5aed",
        "Cancel",
        true,
        ScanMode.QR,
      );
      // $JavaVersion.VERSION_1_8
      Beacondart.addDApp(qrcodeScanRes);
      status = true;
    } on PlatformException {
      qrcodeScanRes = "Error lors du scan";
    }
    return [status, qrcodeScanRes];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: const [
                    Text("Scan Qr Code"),
                    Icon(
                      Icons.camera_alt,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
