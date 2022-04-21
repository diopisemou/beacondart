import 'dart:async';
import 'dart:convert';
import 'package:flutter/src/foundation/print.dart';
import 'package:flutter/services.dart';
import 'package:dart_bs58check/dart_bs58check.dart';

typedef MultiUseCallback = void Function(dynamic response);
typedef CancelListening = void Function();

class BeaconWalletClient {
  static const MethodChannel _channel = MethodChannel('beacondart');

  static const EventChannel _eventChannel = EventChannel('beacondart_receiver');

  static Stream? _onOperationReceiver;

  static bool? isInvalidDappError;

  static List<P2pPeer> peers = [];
  static String? _getDappAddress;
  static String? _getDappImageUrl;
  static String? _getDappName;
  static String? _getDappId;

  // int _nextCallbackId = 0;
  // Map<int, MultiUseCallback> _callbacksById = new Map();
  static final BeaconWalletClient _singleton = BeaconWalletClient._internal();

  // static final Map<int, void Function(MethodCall call)> callbacksById = {};
  static final Map<int, MultiUseCallback> callbacksById = {};

  static int nextCallbackId = 0;

  factory BeaconWalletClient() {
    return _singleton;
  }

  BeaconWalletClient._internal();

  Future<bool> init() async {
    final bool beaconStarted = await _channel.invokeMethod("startBeaconFun");
    return beaconStarted;
  }

  Future<void> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callListener':
        try {
          var funcToCall = callbacksById[call.arguments["id"]];
          //var args = call.arguments["args"];
          var args = call.arguments;
          funcToCall!(args);
          //funcToCall!(args);
        } catch (e) {
          debugPrint(e.toString());
        }
        // callbacksById[call.arguments["id"]]!(call.arguments["args"]);
        break;
      default:
    }
  }

  Future<CancelListening> startListening(MultiUseCallback callback) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod("startListening", currentListenerId);
    return () {
      _channel.invokeMethod("cancelListeningFunc", currentListenerId);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<CancelListening> stopListening() async {
    //int currentListenerId = nextCallbackId++;
    int currentListenerId = nextCallbackId;
    _channel.invokeMethod("cancelListeningFunc", currentListenerId);
    callbacksById.remove(currentListenerId);
    return () {
      _channel.invokeMethod("cancelListeningFunc", currentListenerId);
      callbacksById.remove(currentListenerId);
    };
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  onBeaconRequest(void Function(dynamic response) responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    await _channel.invokeMethod("onBeaconRequestFunc", currentListenerId);
  }

  Future<bool?> onInit() async {
    try {
      dynamic? result = await _channel.invokeMethod('onInitFunc');
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  // Future<bool?> addDApp(dynamic qrcodeScanRes) async {
  //   bool status = false;
  //   try {
  //     // qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //     //   "#4a5aed",
  //     //   "Cancel",
  //     //   true,
  //     //   ScanMode.QR,
  //     // );
  //     status = true;

  //     if (qrcodeScanRes == '-1' || status == false) {
  //       isInvalidDappError = true;
  //     } else {
  //       var dataIndex = qrcodeScanRes.indexOf("data") + 5;
  //       var dappString = qrcodeScanRes.substring(dataIndex); //array[1].toString().length - 1
  //       var decodedValue = bs58check.decoder.convert(dappString);
  //       var dappMeta = String.fromCharCodes(decodedValue);
  //       var dappJson = dappMeta.isNotEmpty ? json.decode(dappMeta) : null;
  //       //
  //       if (dappJson != null) {
  //         var id = dappJson['id'];
  //         var name = dappJson['name'];
  //         var publicKey = dappJson['publicKey'];
  //         var relayServer = dappJson['relayServer'];
  //         var version = dappJson['version'];
  //         var type = dappJson['type'];
  //         _getDappId = id;
  //         _getDappName = name;
  //         _getDappAddress = publicKey;
  //         _getDappImageUrl = relayServer;

  //         onConnectToDApp();
  //         Future.delayed(Duration(milliseconds: 500), () {
  //           this.addPeer(id: id, name: name, publicKey: publicKey, relayServer: relayServer, version: version);
  //         });
  //         // Future.delayed(Duration(milliseconds: 500), () {
  //         //   onConnectToDApp();
  //         // });
  //       }
  //     }
  //   } on PlatformException {
  //     qrcodeScanRes = "Error lors du scan";
  //   } on Exception {
  //     qrcodeScanRes = "Erreur";
  //   }

  //   return true;
  // }

  //addPeers(Map<String, dynamic> dApp) async {}
  //removePeer(Map<String, dynamic> dApp) async {}
  //getPeers() async {}

  // addPeers(Map<String, dynamic> dApp, void Function(dynamic response) responder) async {
  addPeer(Map<String, dynamic> dApp, MultiUseCallback responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    Map params = <String, dynamic>{
      ...dApp,
      'currentListenerId': currentListenerId,
    };
    dynamic? result = await _channel.invokeMethod("addPeerFunc", params);
    peers.add(P2pPeer.fromMap(dApp));

    return () {
      _channel.invokeMethod("cancelListeningFunc", currentListenerId);
      callbacksById.remove(currentListenerId);
    };
  }

  // Future<bool?> addPeer({String? id, String? name, String? publicKey, String? relayServer, String? version}) async {
  //   Map params = <String, String>{
  //     'id': id ?? '',
  //     'name': name ?? '',
  //     'publicKey': publicKey ?? '',
  //     'relayServer': relayServer ?? '',
  //     'version': version ?? '',
  //   };
  //   dynamic? result = await _channel.invokeMethod('addPeerFunc', params);
  //   peers.add(P2pPeer(
  //       id: id,
  //       name: name,
  //       publicKey: publicKey ?? '',
  //       relayServer: relayServer ?? '',
  //       version: version ?? '',
  //       icon: '',
  //       appUrl: ''));
  //   _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
  //   return true;
  // }

  Future<P2pPeer> getPeer() async {
    dynamic? result = await _channel.invokeMethod('getPeerFunc');
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return result;
  }

  Future<List<P2pPeer>> getPeers() async {
    dynamic? result = await _channel.invokeMethod('getPeersFunc');
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return result;
  }

  Future<List<P2pPeer>> removePeer(String? id) async {
    Map params = <String, String>{
      'id': id ?? '',
    };
    dynamic? result = await _channel.invokeMethod('removePeerFunc', params);
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return result;
  }

  Future<List<P2pPeer>> removePeers() async {
    dynamic? result = await _channel.invokeMethod('removePeersFunc');
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return result;
  }

  Future<bool?> onConfirmConnectToDApp() async {
    try {
      await _channel.invokeMethod('onConfirmConnectToDAppFunc');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  Future<bool?> onRejectConnectToDApp() async {
    try {
      await _channel.invokeMethod('onRejectConnectToDAppFunc');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  onConnectToDApp(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      dynamic? result = await _channel.invokeMethod("onConnectToDAppFunc", params);

      return () {
        _channel.invokeMethod("cancelListeningFunc", currentListenerId);
        callbacksById.remove(currentListenerId);
      };

      // var result = await _channel.invokeMethod('onConnectToDAppFunc');
      // _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      // return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }
  // Future<bool?> onConnectToDApp() async {
  //   try {
  //     var result = await _channel.invokeMethod('onConnectToDAppFunc');
  //     _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
  //     return true;
  //   } on PlatformException catch (e) {
  //     debugPrint(e.toString());
  //   } on Exception catch (e) {
  //     debugPrint("Erreur onConnectToDApp");
  //     return false;
  //   }
  // }

  Future<bool?> onDisconnectToDApp(String? id) async {
    try {
      Map params = <String, String>{
        'id': id ?? '',
      };

      var result = await _channel.invokeMethod('onDisconnectToDAppFunc', params);
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  Future<bool?> onSubscribeToRequest() async {
    try {
      var result = await _channel.invokeMethod('onSubscribeToRequestFunc');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur subscribeToRequest");
      return false;
    }
  }

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string. Returns a stream of
  /// detected barcode strings.
  static Stream? getOperationStreamReceiver() {
    // Pass params to the plugin

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    // _channel.invokeMethod('scanBarcode', params);
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return _onOperationReceiver;
  }

  static String? getDappAddress() {
    return _getDappAddress;
  }

  static String? getDappName() {
    return _getDappName;
  }

  static String? getDappId() {
    return _getDappId;
  }

  static String? getDappImageUrl() {
    return _getDappImageUrl;
  }
}

class P2pPeer extends Peer {
  @override
  String? id;
  @override
  String? name;
  @override
  String publicKey;
  String relayServer;
  @override
  String version = "1";
  String? icon;
  String? appUrl;
  @override
  bool isPaired = false;
  @override
  bool isRemoved = false;

  P2pPeer(
      {required this.id,
      required this.name,
      required this.publicKey,
      required this.relayServer,
      required this.version,
      required this.icon,
      required this.appUrl,
      this.isPaired = false,
      this.isRemoved = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'relayServer': relayServer,
      'version': version,
      'icon': icon,
      'appUrl': appUrl,
      'isPaired': isPaired,
      'isRemoved': isRemoved,
    };
  }

  factory P2pPeer.fromMap(Map<String, dynamic> map) {
    return P2pPeer(
        id: map['id'],
        name: map['name'],
        publicKey: map['publicKey'],
        relayServer: map['relayServer'],
        version: map['version'],
        icon: map['icon'],
        appUrl: map['appUrl'],
        isPaired: map['isPaired'] ?? false,
        isRemoved: map['isRemoved'] ?? false);
  }

  String toJson() => json.encode(toMap());

  factory P2pPeer.fromJson(String source) => P2pPeer.fromMap(json.decode(source));

  @override
  Peer paired() {
    return P2pPeer(
      id: id,
      name: name,
      publicKey: publicKey,
      relayServer: relayServer,
      version: version,
      icon: icon,
      appUrl: appUrl,
      isPaired: true,
    );
  }

  @override
  Peer removed() {
    return P2pPeer(
      id: id,
      name: name,
      publicKey: publicKey,
      relayServer: relayServer,
      version: version,
      icon: icon,
      appUrl: appUrl,
      isRemoved: true,
    );
  }
}

abstract class Peer {
  String? id;
  String? name;
  String publicKey = '';
  String version = '';

  bool isPaired = false;
  bool isRemoved = false;

  Peer paired();
  Peer removed();
}
