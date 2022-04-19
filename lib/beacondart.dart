import 'dart:async';

import 'package:flutter/services.dart';

class BeaconWalletClient {
  static const MethodChannel _channel = MethodChannel('beacondart');

  static final BeaconWalletClient _singleton = BeaconWalletClient._internal();

  static final Map<int, void Function(MethodCall call)> callbacksById = {};

  static int nextCallbackId = 0;

  factory BeaconWalletClient() {
    return _singleton;
  }

  BeaconWalletClient._internal();

  Future<bool> init() async {
    final bool beaconStarted = await _channel.invokeMethod("startBeacon");
    return beaconStarted;
  }

  static Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callListener':
        callbacksById[call.arguments["id"]]!(call.arguments["args"]);
        break;
      default:
    }
  }

  addPeer(Map<String, dynamic> dApp) async {}
  removePeer(Map<String, dynamic> dApp) async {}
  getPeers() async {}
  onBeaconRequest(void Function(dynamic response) responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    await _channel.invokeMethod("onBeaconRequest", currentListenerId);
  }
}
