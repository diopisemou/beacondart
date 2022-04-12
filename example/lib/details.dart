import 'package:beacondart/beacondart.dart';
import 'package:flutter/material.dart';

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
                    Beacondart.onDisconnectToDApp(widget.dappId);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(children: const [
                      Text("Disconnec"),
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
