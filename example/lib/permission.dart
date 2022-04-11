import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:beacondart/beacondart.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class Permission extends StatefulWidget {
  final String dappImageUrl;
  final String dappName;
  final String dappAddress;
  const Permission({Key? key, required this.dappImageUrl, required this.dappName, required this.dappAddress})
      : super(key: key);

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  bool isInvalidDappError = false;

  @override
  void initState() {
    super.initState();
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
              const SizedBox(height: 20),
              Image(image: NetworkImage(widget.dappImageUrl)),
              const SizedBox(height: 20),
              Text('Dapp Name on: ${widget.dappName} \n'),
              const SizedBox(height: 20),
              Text('Public address : ${widget.dappAddress} \n'),
              const SizedBox(height: 20),

              ///Scan Icon
              GestureDetector(
                  onTap: () async {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(children: const [
                      Text("Connect"),
                      Icon(
                        Icons.check,
                        size: 50,
                      ),
                    ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
