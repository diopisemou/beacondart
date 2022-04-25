import 'dart:async';

import 'package:flutter/services.dart';

class BeaconWalletClient {
  static const MethodChannel _channel = MethodChannel('beacondart');

  static final BeaconWalletClient _singleton = BeaconWalletClient._internal();

  static final Map<int, void Function(MethodCall call)> callbacksById = {};

  static int nextCallbackId = 0;

  bool beaconIsInit = false;

  factory BeaconWalletClient() {
    return _singleton;
  }

  BeaconWalletClient._internal();

  Future<bool> init(String appName, String publicKey, String address) async {
    await _startBeacon(<String, String>{
      'appName': appName,
      'publicKey': publicKey,
      'address': address,
    });
    // user completer to check beaconIsInit
    Completer<bool> completer = Completer();

    int tries = 1;
    int n = 0;
    int seconds = 4;

    check(int tries) {
      seconds = seconds ~/ tries;

      if (seconds < 1) {
        completer.completeError(
            "Gave up waiting for wallet service after $tries tries in $n seconds. ...");
      }

      n += seconds;
      print(beaconIsInit);
      if (beaconIsInit) {
        completer.complete(true);
      } else {
        Duration timeout = Duration(seconds: seconds);
        Timer(timeout, () => check(++tries));
      }
    }

    check(tries);

    return completer.future;
  }

  static Future<void> methodCallHandler(MethodCall call) async {
    print('called...');
    switch (call.method) {
      case 'callListener':
        callbacksById[call.arguments["id"]]!(call.arguments["args"]);
        break;
      default:
    }
  }

  Future<bool> addPeer(Map<String, String> dApp) async {
    final bool status = await _channel.invokeMethod("addPeer", <String, String>{
      "id": dApp["id"]!,
      "name": dApp["name"]!,
      "publicKey": dApp["publicKey"]!,
      "relayServer": dApp["relayServer"]!,
      "version": dApp["version"]!
    });
    return status;
  }

  Future<bool> removePeer(String peerPublicKey) async {
    final bool status = await _channel.invokeMethod(
      "removePeer",
      peerPublicKey,
    );
    return status;
  }

  Future<bool> removePeers() async {
    final bool status = await _channel.invokeMethod("removePeers");
    return status;
  }

  getPeers(void Function(dynamic response) responder) async {
    void Function() cancel = await callBackRequest(
      "getPeers",
      responder,
    );
    return cancel;
  }

  Future<void Function()> onBeaconRequest(
    void Function(dynamic response) responder,
  ) async {
    void Function() cancel = await callBackRequest(
      "onBeaconRequest",
      responder,
    );
    return cancel;
  }

  _startBeacon(
    Map<String, String> args,
  ) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = (response) {
      print(response);
      beaconIsInit = true;
    };
    await _channel.invokeMethod(
      "startBeacon",
      {
        "callBackId": currentListenerId,
        ...args,
      },
    );
    return () {
      _channel.invokeMethod(
        "cancelListening",
        currentListenerId,
      );
      callbacksById.remove(currentListenerId);
    };
  }

  Future<void Function()> callBackRequest(
    String callBack,
    void Function(dynamic response) responder,
  ) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    await _channel.invokeMethod(
      callBack,
      currentListenerId,
    );
    return () {
      _channel.invokeMethod(
        "cancelListening",
        currentListenerId,
      );
      callbacksById.remove(currentListenerId);
    };
  }
}
