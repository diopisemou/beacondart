import 'dart:convert';

class P2pPeer extends Peer {
  @override
  late String? id;
  @override
  late String? name;
  @override
  late String publicKey;
  late String relayServer;
  @override
  late String version = "1";
  late String icon;
  late String? appUrl;
  late bool isDappConnected = false;
  @override
  late bool isPaired = false;
  @override
  late bool isRemoved = false;

  P2pPeer(
      {required this.id,
      required this.name,
      required this.publicKey,
      required this.relayServer,
      required this.version,
      required this.icon,
      required this.appUrl,
      this.isDappConnected = false,
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
      'isDappConnected': isDappConnected,
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
        icon: map['icon'] ?? '',
        appUrl: map['appUrl'],
        isDappConnected: map['isDappConnected'] ?? false,
        isPaired: map['isPaired'] ?? false,
        isRemoved: map['isRemoved'] ?? false);
  }

  String toJson() => json.encode(toMap());

  factory P2pPeer.fromJson(String source) => P2pPeer.fromMap(json.decode(source));

  Peer connected() {
    return P2pPeer(
      id: id,
      name: name,
      publicKey: publicKey,
      relayServer: relayServer,
      version: version,
      icon: icon,
      appUrl: appUrl,
      isDappConnected: true,
    );
  }

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
  bool isDappConnected = false;

  Peer paired();
  Peer removed();
}

class AppMetadata {
  String? senderId;
  String? name;
  String? icon = '';
  String? blockchainIdentifier = '';
  String? appUrl = '';

  AppMetadata(
      {required this.senderId,
      required this.name,
      required this.icon,
      required this.blockchainIdentifier,
      required this.appUrl});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'name': name,
      'icon': icon,
      'blockchainIdentifier': blockchainIdentifier,
      'appUrl': appUrl,
    };
  }

  factory AppMetadata.fromMap(Map<String, dynamic> map) {
    return AppMetadata(
      senderId: map['senderId'],
      name: map['name'],
      icon: map['icon'],
      blockchainIdentifier: map['blockchainIdentifier'],
      appUrl: map['appUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppMetadata.fromJson(String source) => AppMetadata.fromMap(json.decode(source));
}
