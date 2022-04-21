// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:beacondart_platform_interface/types/types.dart';

import '../platform_interface/beacondart_platform.dart';

const MethodChannel _channel = MethodChannel('beacondart');

/// An implementation of [BeacondartPlatform] that uses method channels.
class MethodChannelBeacondart extends BeacondartPlatform {
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

  @override
  addPeer(Map<String, dynamic> dApp, BeacondartHandler? handler) async {
    await channel.invokeMethod<void>('addPeerFunc', dApp);
  }

  @override
  addPeers(List<Map<String, dynamic>> dApp, BeacondartHandler? handler) async {
    await channel.invokeMethod<void>('addPeerFunc', dApp);
  }
}
