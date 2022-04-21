import 'package:beacondart/beacondart_android.dart';
import 'package:beacondart_example/details.dart';
import 'package:flutter/material.dart';

class PermissionPage extends StatefulWidget {
  final String dappImageUrl;
  final String dappName;
  final String dappId;
  final String dappAddress;
  final String dappScope;
  final String dappBlockChain;
  final String dappNetwork;
  const PermissionPage(
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
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool isInvalidDappError = false;
  BeaconWalletClient bmw = BeaconWalletClient();

  @override
  void initState() {
    super.initState();
  }

  void goToDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          dappAddress: BeaconWalletClient.getDappAddress() ?? '',
          dappImageUrl: BeaconWalletClient.getDappImageUrl() ?? '',
          dappName: BeaconWalletClient.getDappName() ?? '',
          dappId: BeaconWalletClient.getDappName() ?? '',
          dappBlockChain: widget.dappBlockChain,
          dappNetwork: widget.dappNetwork,
          dappScope: widget.dappScope,
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
              widget.dappImageUrl.isNotEmpty ? Image(image: NetworkImage(widget.dappImageUrl)) : Container(),
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
                    bmw.onRejectConnectToDApp((response) async {
                      setState(() {
                        debugPrint(response.toString());
                      });
                    });
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
                    bmw.onConfirmConnectToDApp((response) async {
                      setState(() {
                        debugPrint(response.toString());
                      });
                    });
                    goToDetails();
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
