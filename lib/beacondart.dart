
import 'dart:async';

import 'package:flutter/services.dart';

class Beacondart {
  static const MethodChannel _channel = MethodChannel('beacondart');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
