import 'dart:async';
import 'dart:convert';
import 'dart:html';
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
        completer.completeError("Gave up waiting for wallet service after $tries tries in $n seconds. ...");
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

  Future<void> methodCallHandler(MethodCall call) async {
    print('called');
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
      "startBeaconFun",
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
      Map params = <String, dynamic>{
        ...dApp,
      };

      void Function() cancel = await callBackRequest(
        "addPeerFunc",
        params,
        responder,
      );

      peers.add(P2pPeer.fromMap(dApp));

      _getDappId = dApp['id'];
      _getDappName = dApp['name'];
      _getDappImageUrl = dApp['icon'];
      _getDappAddress = dApp['publicKey'];

      return cancel;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  getPeer(String? id, MultiUseCallback responder) async {
    Map params = <String, dynamic>{
      'id': id ?? '',
    };
    void Function() cancel = await callBackRequest(
      "getPeerFunc",
      params,
      responder,
    );
    return cancel;
  }

  //  getPeer(String? id, MultiUseCallback responder) async {
  //   _channel.setMethodCallHandler(methodCallHandler);
  //   int currentListenerId = nextCallbackId++;
  //   callbacksById[currentListenerId] = responder;
  //   Map params = <String, dynamic>{
  //     'id': id ?? '',
  //     'currentListenerId': currentListenerId,
  //   };

  //   await _channel.invokeMethod('getPeerFunc');

  //   return () {
  //     _channel.invokeMethod("cancelListeningFunc", params);
  //     callbacksById.remove(currentListenerId);
  //   };
  // }

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
      Map params = <String, dynamic>{
        'accountAddress': accountAddress,
        'accountPubKey': accountPubKey,
        'isBase64': isBase64,
      };
      void Function() cancel = await callBackRequest(
        "onConfirmConnectToDAppFunc",
        params,
        responder,
      );
      return cancel;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  onRejectConnectToDApp(MultiUseCallback responder) async {
    try {
      void Function() cancel = await callBackRequest(
        "onRejectConnectToDAppFunc",
        null,
        responder,
      );
      return cancel;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  Future<CancelListening> onConnectToDApp(MultiUseCallback responder) async {
    try {
      void Function() cancel = await callBackRequest(
        "onConnectToDAppFunc",
        null,
        responder,
      );
      return cancel;
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
      Map params = <String, dynamic>{
        'id': id ?? '',
      };

      void Function() cancel = await callBackRequest(
        "onDisconnectToDAppFunc",
        params,
        responder,
      );
      return cancel;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  onSubscribeToRequest(MultiUseCallback responder) async {
    try {
      void Function() cancel = await callBackRequest(
        "onSubscribeToRequestFunc",
        null,
        responder,
      );
      return cancel;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur subscribeToRequest");
      return false;
    }
  }

  onConfirmOperationRequest(Map reqArgs, MultiUseCallback responder) async {
    try {
      Map params = <String, dynamic>{
        ...reqArgs,
      };
      void Function() cancel = await callBackRequest(
        "onConfirmOperationRequestFunc",
        params,
        responder,
      );
      return cancel;
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

  Future<void Function()> onRequestBeacon(
    void Function(dynamic response) responder,
  ) async {
    void Function() cancel = await callBackRequest(
      "onBeaconRequest",
      null,
      responder,
    );
    return cancel;
  }

  Future<void Function()> callBackRequest(
    String callBack,
    Map? reqArgs,
    MultiUseCallback responder,
    //void Function(dynamic response) responder,
  ) async {
    // _channel.setMethodCallHandler(methodCallHandler);
    // int currentListenerId = nextCallbackId++;
    // callbacksById[currentListenerId] = responder;

    _channel.setMethodCallHandler(methodCallHandler);
    int? currentListenerId;
    if (responder != null) {
      currentListenerId = nextCallbackId++;
      callbacksById[currentListenerId] = responder;
    }

    Map params = <String, dynamic>{
      'currentListenerId': currentListenerId,
      ...?reqArgs,
    };
    await _channel.invokeMethod(
      callBack,
      params,
    );
    return () {
      _channel.invokeMethod(
        "cancelListeningFunc",
        params,
        // currentListenerId,
      );
      callbacksById.remove(currentListenerId);
    };
  }
}
