// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:beacondart_platform_interface/beacondart_platform_interface.dart';
export 'package:beacondart_platform_interface/types/types.dart';

const MethodChannel _channel = MethodChannel('beacondart_android');

/// An implementation of [BeacondartPlatform] that for Android.
class BeacondartAndroid extends BeacondartPlatform {
  /// Registers this class as the default instance of [BeacondartPlatform].
  static void registerWith() {
    BeacondartPlatform.instance = BeacondartAndroid();
  }

  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  @override
  Future<void> initialize(BeacondartHandler? handler) async {
    channel.setMethodCallHandler((MethodCall call) async {
      assert(call.method == 'launch');
      handler!(call.arguments as String);
    });
    final String? action = await channel.invokeMethod<String?>('getLaunchAction');
    if (action != null) {
      handler!(action);
    }
  }
}
