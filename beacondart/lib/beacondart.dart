import 'dart:async';
import 'dart:convert';
import 'package:beacondart_platform_interface/types/types.dart';
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
    Map params = <String, dynamic>{
      'currentListenerId': currentListenerId,
    };
    return () {
      //_channel.invokeMethod("cancelListeningFunc", currentListenerId);
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<CancelListening> stopListening() async {
    //int currentListenerId = nextCallbackId++;
    int currentListenerId = nextCallbackId;
    _channel.invokeMethod("cancelListeningFunc", currentListenerId);
    callbacksById.remove(currentListenerId);
    Map params = <String, dynamic>{
      'currentListenerId': currentListenerId,
    };
    return () {
      //_channel.invokeMethod("cancelListeningFunc", currentListenerId);
      _channel.invokeMethod("cancelListeningFunc", params);
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

    _getDappId = dApp['id'];
    _getDappName = dApp['name'];
    _getDappImageUrl = dApp['icon'];
    _getDappAddress = dApp['publicKey'];
    _getDappImageUrl = dApp['relayServer'];

    return () {
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);
    };
  }

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

  onConfirmConnectToDApp(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      await _channel.invokeMethod('onConfirmConnectToDAppFunc');
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  onRejectConnectToDApp(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      await _channel.invokeMethod('onRejectConnectToDAppFunc', params);
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
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
      // dynamic? result = await _channel.invokeMethod("onConnectToDAppFunc", params);
      await _channel.invokeMethod("onConnectToDAppFunc", params);
      //_onOperationReceiver ??= _eventChannel.receiveBroadcastStream();

      return () {
        //_channel.invokeMethod("cancelListeningFunc", currentListenerId);
        _channel.invokeMethod("cancelListeningFunc", params);
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
  Stream? getOperationStreamReceiver() {
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
