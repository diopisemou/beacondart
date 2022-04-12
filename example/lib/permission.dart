import 'package:beacondart/beacondart.dart';
import 'package:flutter/material.dart';

class PermissionPage extends StatefulWidget {
  final String dappImageUrl;
  final String dappName;
  final String dappAddress;
  final String dappScope;
  final String dappBlockChain;
  final String dappNetwork;
  const PermissionPage(
      {Key? key,
      required this.dappImageUrl,
      required this.dappName,
      required this.dappAddress,
      required this.dappScope,
      required this.dappBlockChain,
      required this.dappNetwork})
      : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
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
              Text('Dapp Blockchain : ${widget.dappBlockChain} \n'),
              const SizedBox(height: 20),

              Text('Dapp Network : ${widget.dappNetwork} \n'),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              // Image(image: NetworkImage(widget.dappImageUrl)),
              const SizedBox(height: 20),
              Text('Dapp Name on: ${widget.dappName} \n'),
              const SizedBox(height: 20),
              Text('Public address : ${widget.dappAddress} \n'),
              const SizedBox(height: 20),
              Text('Dapp Scope : ${widget.dappScope} \n'),
              const SizedBox(height: 20),

              ///Scan Icon
              GestureDetector(
                  onTap: () async {
                    Beacondart.onRejectConnectToDApp();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(children: const [
                      Text("Cancel"),
                      Icon(
                        Icons.check,
                        size: 50,
                      ),
                    ]),
                  )),

              GestureDetector(
                  onTap: () async {
                    Beacondart.onConfirmConnectToDApp();
                  },
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
