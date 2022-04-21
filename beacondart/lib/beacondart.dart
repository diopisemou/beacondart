// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:beacondart_platform_interface/platform_interface/beacondart_platform.dart';
import 'package:beacondart_platform_interface/types/types.dart';

export 'package:beacondart_platform_interface/types/types.dart';
import 'dart:async';
import 'dart:convert';
import 'package:beacondart_platform_interface/types/types.dart';
import 'package:flutter/src/foundation/print.dart';
import 'package:flutter/services.dart';
import 'package:dart_bs58check/dart_bs58check.dart';

/// Quick actions plugin.
class BeaconWalletClient {
  /// Creates a new instance of [QuickActions].
  const BeaconWalletClient();

  /// Initializes this plugin.
  ///
  /// Call this once before any further interaction with the plugin.
  Future<void> initialize(BeacondartHandler handler) async => BeacondartPlatform.instance.initialize(handler);
}
