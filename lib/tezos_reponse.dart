import 'dart:convert';
import 'dart:ffi';

abstract class BlockchainTezosResponse {
  String? id;
  String? blockchainIdentifier;
  String? type;
  String? senderId;
  String? version;
}

class PermissionTezosResponse implements BlockchainTezosResponse {
  Map? account;
  List<dynamic>? scopes;

  @override
  String? blockchainIdentifier;

  @override
  String? id;

  @override
  String? senderId;

  @override
  String? type;

  @override
  String? version;

  PermissionTezosResponse({
    required this.id,
    required this.blockchainIdentifier,
    required this.type,
    required this.senderId,
    required this.version,
    this.account,
    this.scopes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockchainIdentifier': blockchainIdentifier,
      'type': type,
      'senderId': senderId,
      'version': version,
      'account': account,
      'scopes': scopes,
    };
  }

  factory PermissionTezosResponse.fromMap(Map<String, dynamic> map) {
    return PermissionTezosResponse(
      id: map['id'],
      blockchainIdentifier: map['blockchainIdentifier'],
      type: map['type'],
      senderId: map['senderId'],
      version: map['version'],
      account: map['account'],
      scopes: map['scopes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PermissionTezosResponse.fromJson(String source) => PermissionTezosResponse.fromMap(json.decode(source));
}

// {
//     "type": "tezos_permission_response",
//     "id": "da3b5cf2-90b5-4a55-7aae-92aacd00375e",
//     "version": "2",
//     "blockchainIdentifier": "tezos",
//     "account": {
//         "accountId": "MNGP6zgrUEoincgyBjR",
//         "network": {
//             "type": "mainnet"
//         },
//         "publicKey": "{\"type\":\"tezos_permission_request\",\"id\":\"da3b5cf2-90b5-4a55-7aae-92aacd00375e\",\"version\":\"2\",\"blockchainIdentifier\":\"tezos\",\"senderId\":\"23QQgSvWM9CTv\",\"appMetadata\":{\"senderId\":\"23QQgSvWM9CTv\",\"name\":\"objkt.com\",\"icon\":\"https://assets.objkt.media/file/assets-002/objkt/objkt-logo.png\",\"blockchainIdentifier\":\"tezos\"},\"origin\":{\"type\":\"p2p\",\"id\":\"fa3c00f2da741327ab92f323024d4c5775bd6544ad9a2a3d8cc2396876fe4574\"},\"network\":{\"type\":\"mainnet\"},\"scopes\":[\"operation_request\",\"sign\"]}",
//         "address": ""
//     },
//     "scopes": [
//         "operation_request",
//         "sign"
//     ]
// }