import 'dart:async';
import 'dart:convert';
import 'package:beacondart/p2ppeer.dart';
import 'package:beacondart/tezos_reponse.dart';
import 'package:beacondart/tezos_request.dart';
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

  //onBeaconRequest(void Function(dynamic response) responder) async {
  onBeaconRequest(MultiUseCallback responder) async {
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

  addPeer(Map<String, dynamic> dApp, MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int? currentListenerId;
      if (responder != null) {
        currentListenerId = nextCallbackId++;
        callbacksById[currentListenerId] = responder;
      }
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

  getPeer(String? id, MultiUseCallback responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    Map params = <String, dynamic>{
      'id': id ?? '',
      'currentListenerId': currentListenerId,
    };

    await _channel.invokeMethod('getPeerFunc');

    return () {
      _channel.invokeMethod("cancelListeningFunc", params);
      callbacksById.remove(currentListenerId);
    };
  }

  Future<List<P2pPeer>> getPeers(MultiUseCallback responder) async {
    _channel.setMethodCallHandler(methodCallHandler);
    int currentListenerId = nextCallbackId++;
    callbacksById[currentListenerId] = responder;
    Map params = <String, dynamic>{
      'currentListenerId': currentListenerId,
    };
    dynamic? result = await _channel.invokeMethod('getPeersFunc', params);
    var resultData = json.decode(result);
    peers = resultData.map<P2pPeer>((dynamic d) => P2pPeer.fromMap(d)).toList();
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    result = peers;
    return result;
  }

  Future<List<P2pPeer>> removePeer(String? id, Map<String, dynamic>? dApp) async {
    Map params = <String, dynamic>{
      'peer': dApp ?? null,
      'id': id ?? '',
    };
    dynamic? result = await _channel.invokeMethod('removePeerFunc', params);
    peers.removeWhere((element) => element.id == id);
    result = peers;
    return result;
  }

  Future<List<P2pPeer>> removePeers() async {
    dynamic? result = await _channel.invokeMethod('removePeersFunc');
    peers.clear();
    result = peers;
    return result;
  }

  onConfirmConnectToDApp(String accountAddress, String accountPubKey, bool isBase64, MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
        // 'accountAddress': 'tz1N6Dqo9PuWga38GjdfPXg1aSowbymWinGK',
        // 'accountPubKey': 'edpkvR6cRnbyA2gsLvMnjwnJ7rH3vUpN9ULcdA6mtJZrkVEeiN6EVe',
        // 'isBase64': false,
        'accountAddress': accountAddress,
        'accountPubKey': accountPubKey,
        'isBase64': isBase64,
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
      int? currentListenerId;
      if (responder != null) {
        currentListenerId = nextCallbackId++;
        callbacksById[currentListenerId] = responder;
      }
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      await _channel.invokeMethod("onConnectToDAppFunc", params);
      //debugPrint(result.toString());
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

  onConfirmOperationRequest(Map reqArgs, MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
        ...reqArgs,
      };
      var result = await _channel.invokeMethod('onConfirmOperationRequestFunc', params);
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

  onOperationRequest(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      _onOperationReceiver?.listen((event) {
        var eventMap = json.decode(event);

        if (eventMap['type'] == "tezos_operation_request") {
          responder!(OperationTezosRequest.fromJson(event));
        }
        if (eventMap['type'] == "tezos_sign_payload_request") {
          responder!(SignPayloadTezosRequest.fromJson(event));
        }
      });
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onOperationRequest");
      return false;
    }
  }

  onPermissionRequest(MultiUseCallback responder) async {
    try {
      _channel.setMethodCallHandler(methodCallHandler);
      int currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
      Map params = <String, dynamic>{
        'currentListenerId': currentListenerId,
      };
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      _onOperationReceiver?.listen((event) {
        var eventMap = json.decode(event);
        //tezos_permission_request
        if (eventMap['type'] == "tezos_permission_request") {
          responder!(PermissionTezosRequest.fromJson(event));
        }
        if (eventMap['type'] == "tezos_permission_response") {
          responder!(PermissionTezosResponse.fromJson(event));
        }
        if (eventMap['type'] == "tezos_operation_request") {
          responder!(OperationTezosRequest.fromJson(event));
        }
        if (eventMap['type'] == "tezos_sign_payload_request") {
          responder!(SignPayloadTezosRequest.fromJson(event));
        }
      });
      return () {
        _channel.invokeMethod("cancelListeningFunc", params);
        callbacksById.remove(currentListenerId);
      };
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onOperationRequest $e");
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
