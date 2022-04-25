import 'dart:async';
import 'package:beacondart/p2ppeer.dart';
import 'package:flutter/src/foundation/print.dart';
import 'package:flutter/services.dart';

typedef MultiUseCallback = void Function(dynamic response)?;
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
          var args = call.arguments;
          if (funcToCall != null) {
            funcToCall(args);
          }
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
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<CancelListening> stopListening() async {
    try {
      int currentListenerId = nextCallbackId--;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);

      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } catch (e) {
      debugPrint(e.toString());
      return () {};
    }
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
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        ...dApp,
        'currentListenerId': currentListenerId,
      };
      await _channel.invokeMethod("addPeerFunc", params);
      peers.add(P2pPeer.fromMap(dApp));

      _getDappId = dApp['id'];
      _getDappName = dApp['name'];
      _getDappImageUrl = dApp['icon'];
      _getDappAddress = dApp['publicKey'];

      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  getPeer(MultiUseCallback responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    Map params = <String, dynamic>{
      'currentListenerId': currentListenerId,
    };

    await _channel.invokeMethod('getPeerFunc');

    return () {
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);
    };
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
    return result;
  }

  Future<List<P2pPeer>> removePeers() async {
    dynamic? result = await _channel.invokeMethod('removePeersFunc');
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
      var result = await _channel.invokeMethod('onConfirmConnectToDAppFunc', params);
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

  Future<CancelListening> onConnectToDApp(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      var result = await _channel.invokeMethod("onConnectToDAppFunc", params);
      debugPrint(result.toString());
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return () {};
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return () {};
    }
  }

  onDisconnectToDApp(String? id, MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'id': id ?? '',
        'currentListenerId': currentListenerId,
      };

      var result = await _channel.invokeMethod('onDisconnectToDAppFunc', params);
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

  onSubscribeToRequest(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };

      await _channel.invokeMethod('onSubscribeToRequestFunc', params);
      //_onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
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

  String? getDappAddress() {
    return _getDappAddress;
  }

  String? getDappName() {
    return _getDappName;
  }

  String? getDappId() {
    return _getDappId;
  }

  String? getDappImageUrl() {
    return _getDappImageUrl;
  }

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
