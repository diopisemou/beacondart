// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:beacondart_platform_interface/types/types.dart';

import '../method_channel/method_channel_beacondart.dart';

/// The interface that implementations of quick_actions must implement.
///
/// Platform implementations should extend this class rather than implement it as `quick_actions`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [BeacondartPlatform] methods.
abstract class BeacondartPlatform extends PlatformInterface {
  /// Constructs a QuickActionsPlatform.
  BeacondartPlatform() : super(token: _token);

  static final Object _token = Object();

  static BeacondartPlatform _instance = MethodChannelBeacondart();

  /// The default instance of [BeacondartPlatform] to use.
  ///
  /// Defaults to [MethodChannelBeacondart].
  static BeacondartPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [QuickActionsPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(BeacondartPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Initializes this plugin.
  ///
  /// Call this once before any further interaction with the plugin.
  Future<void> initialize(BeacondartHandler? handler) async {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  addPeers(List<Map<String, dynamic>> dApp, BeacondartHandler? handler) async {
    throw UnimplementedError('addPeers() has not been implemented.');
  }

  addPeer(Map<String, dynamic> dApp, BeacondartHandler? handler) async {
    throw UnimplementedError('addPeer() has not been implemented.');
  }

  removePeer(Map<String, dynamic> dApp, BeacondartHandler? handler) async {
    throw UnimplementedError('removePeer() has not been implemented.');
  }

  removePeers(BeacondartHandler? handler) async {
    throw UnimplementedError('removePeers() has not been implemented.');
  }

  getPeer(String? id, BeacondartHandler? handler) async {
    throw UnimplementedError('getPeer() has not been implemented.');
  }

  getPeers(BeacondartHandler? handler) async {
    throw UnimplementedError('getPeers() has not been implemented.');
  }
}
