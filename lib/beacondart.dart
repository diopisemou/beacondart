import 'dart:async';
import 'dart:convert';
import 'package:flutter/src/foundation/print.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:dart_bs58check/dart_bs58check.dart';

class Beacondart {
  static const MethodChannel _channel = MethodChannel('beacondart');

  static const EventChannel _eventChannel = EventChannel('beacondart_request_receiver');
  //static const EventChannel _eventReqChannel = EventChannel('beacondart_request_receiver');
  //static const EventChannel _eventRespChannel = EventChannel('beacondart_response_receiver');

  static Stream? _onOperationReceiver;
  //static Stream? _onOperationRequestReceiver;
  //static Stream? _onOperationResponseReceiver;

  static bool? isInvalidDappError;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool?> onInit() async {
    try {
      dynamic? result = await _channel.invokeMethod('onInit');
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<bool?> addDApp() async {
    dynamic qrcodeScanRes = '';
    bool status = false;
    try {
      qrcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#4a5aed",
        "Cancel",
        true,
        ScanMode.QR,
      );
      status = true;

      if (qrcodeScanRes == '-1' || status == false) {
        isInvalidDappError = true;
      } else {
        var dataIndex = qrcodeScanRes.indexOf("data") + 5;
        var dappString = qrcodeScanRes.substring(dataIndex); //array[1].toString().length - 1
        var decodedValue = bs58check.decoder.convert(dappString);
        var dappMeta = String.fromCharCodes(decodedValue);
        var dappJson = dappMeta.isNotEmpty ? json.decode(dappMeta) : null;
        //
        if (dappJson != null) {
          var id = dappJson['id'];
          var name = dappJson['name'];
          var publicKey = dappJson['publicKey'];
          var relayServer = dappJson['relayServer'];
          var version = dappJson['version'];
          var type = dappJson['type'];
          addPeer(id: id, name: name, publicKey: publicKey, relayServer: relayServer, version: version);
          Future.delayed(Duration(milliseconds: 500), () {
            onConnectToDApp();
          });
        }
      }
    } on PlatformException {
      qrcodeScanRes = "Error lors du scan";
    } on Exception {
      qrcodeScanRes = "Erreur";
    }

    return true;
  }

  static Future<bool?> addPeer(
      {String? id, String? name, String? publicKey, String? relayServer, String? version}) async {
    Map params = <String, String>{
      'id': id ?? '',
      'name': name ?? '',
      'publicKey': publicKey ?? '',
      'relayServer': relayServer ?? '',
      'version': version ?? '',
    };
    dynamic? result = await _channel.invokeMethod('addPeer', params);
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return true;
  }

  static Future<bool?> onConfirmConnectToDApp() async {
    try {
      var result = await _channel.invokeMethod('onConfirmConnectToDApp');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  static Future<bool?> onRejectConnectToDApp() async {
    try {
      var result = await _channel.invokeMethod('onRejectConnectToDApp');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  static Future<bool?> onConnectToDApp() async {
    try {
      var result = await _channel.invokeMethod('onConnectToDApp');
      _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
      return true;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    } on Exception catch (e) {
      debugPrint("Erreur onConnectToDApp");
      return false;
    }
  }

  static Future<bool?> onSubscribeToRequest() async {
    try {
      var result = await _channel.invokeMethod('onSubscribeToRequest');
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

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string. Returns a stream of
  /// detected barcode strings.
  static Stream? getOperationRequestStreamReceiver() {
    // Pass params to the plugin

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    // _channel.invokeMethod('scanBarcode', params);
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return _onOperationReceiver;
  }

  /// Returns a continuous stream of barcode scans until the user cancels the
  /// operation.
  ///
  /// Shows a scan line with [lineColor] over a scan window. A flash icon is
  /// displayed if [isShowFlashIcon] is true. The text of the cancel button can
  /// be customized with the [cancelButtonText] string. Returns a stream of
  /// detected barcode strings.
  static Stream? getOperationResponseStreamReceiver() {
    // Pass params to the plugin

    // Invoke method to open camera, and then create an event channel which will
    // return a stream
    // _channel.invokeMethod('scanBarcode', params);
    _onOperationReceiver ??= _eventChannel.receiveBroadcastStream();
    return _onOperationReceiver;
  }
}
