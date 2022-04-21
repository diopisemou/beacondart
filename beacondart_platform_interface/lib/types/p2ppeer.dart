// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

class P2pPeer extends Peer {
  @override
  String? id;
  @override
  String? name;
  @override
  String publicKey;
  String relayServer;
  @override
  String version = "1";
  String? icon;
  String? appUrl;
  @override
  bool isPaired = false;
  @override
  bool isRemoved = false;

  P2pPeer(
      {required this.id,
      required this.name,
      required this.publicKey,
      required this.relayServer,
      required this.version,
      required this.icon,
      required this.appUrl,
      this.isPaired = false,
      this.isRemoved = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
      'relayServer': relayServer,
      'version': version,
      'icon': icon,
      'appUrl': appUrl,
      'isPaired': isPaired,
      'isRemoved': isRemoved,
    };
  }

  factory P2pPeer.fromMap(Map<String, dynamic> map) {
    return P2pPeer(
        id: map['id'],
        name: map['name'],
        publicKey: map['publicKey'],
        relayServer: map['relayServer'],
        version: map['version'],
        icon: map['icon'],
        appUrl: map['appUrl'],
        isPaired: map['isPaired'] ?? false,
        isRemoved: map['isRemoved'] ?? false);
  }

  String toJson() => json.encode(toMap());

  factory P2pPeer.fromJson(String source) => P2pPeer.fromMap(json.decode(source));

  @override
  Peer paired() {
    return P2pPeer(
      id: id,
      name: name,
      publicKey: publicKey,
      relayServer: relayServer,
      version: version,
      icon: icon,
      appUrl: appUrl,
      isPaired: true,
    );
  }

  @override
  Peer removed() {
    return P2pPeer(
      id: id,
      name: name,
      publicKey: publicKey,
      relayServer: relayServer,
      version: version,
      icon: icon,
      appUrl: appUrl,
      isRemoved: true,
    );
  }
}

abstract class Peer {
  String? id;
  String? name;
  String publicKey = '';
  String version = '';

  bool isPaired = false;
  bool isRemoved = false;

  Peer paired();
  Peer removed();
}
