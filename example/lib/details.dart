import 'dart:convert';

import 'package:beacondart/beacondart.dart';
import 'package:beacondart/tezos_reponse.dart';
import 'package:beacondart/tezos_request.dart';
import 'package:beacondart_example/operations.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class DetailsPage extends StatefulWidget {
  final String dappImageUrl;
  final String dappName;
  final String dappId;
  final String dappAddress;
  final String dappScope;
  final String dappBlockChain;
  final String dappNetwork;
  const DetailsPage(
      {Key? key,
      required this.dappImageUrl,
      required this.dappName,
      required this.dappId,
      required this.dappAddress,
      required this.dappScope,
      required this.dappBlockChain,
      required this.dappNetwork})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isInvalidDappError = false;
  BeaconWalletClient bmw = BeaconWalletClient();

  @override
  void initState() {
    super.initState();

    bmw.onSubscribeToRequest((response) {
      debugPrint('onSubscribeToRequest: $response');
    });
    bmw.getOperationStreamReceiver()?.listen((barcode) {
      var requestMap = json.decode(barcode);
      if (requestMap['type'] == "tezos_operation_request") {
        goToOperations(OperationTezosRequest.fromJson(requestMap));
      }
      if (requestMap['type'] == "tezos_permission_response") {
        var response = PermissionTezosResponse.fromJson(requestMap);
        if (response.account!['publicKey'] != '' && response.account!['address'] != '') {
          goToOperations(response);
        }
      }
    });

    bmw.onPermissionRequest((dynamic barcode) {
      debugPrint("onPermissionRequest: $barcode");
    });
  }

  void goToOperations(dynamic requestMap) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OperationsPage(
          dappAddress: bmw.getDappAddress() ?? '',
          dappImageUrl: bmw.getDappImageUrl() ?? '',
          dappName: bmw.getDappName() ?? '',
          dappId: bmw.getDappName() ?? '',
          dappBlockChain: requestMap.appMetadata['blockchainIdentifier'],
          dappNetwork: requestMap.network['type'],
        ),
      ),
    );
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
                    bmw.onDisconnectToDApp(widget.dappId, null);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute<void>(builder: (BuildContext context) => const MyApp()),
                    //   ModalRoute.withName('/'),
                    // );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(children: const [
                      Text("Disconnect"),
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
