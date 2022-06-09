import 'dart:convert';
import 'dart:ffi';

import 'package:beacondart/p2ppeer.dart';

abstract class BlockchainTezosRequest {
  String? id;
  String? blockchainIdentifier;
  String? type;
  String? senderId;
  String? version;
}

class OperationDetails {
  String? storageLimit;
  String? amount;
  String? destination = '';
  String? kind = '';
  Map? parameters;

  OperationDetails({
    this.storageLimit,
    this.amount,
    this.destination,
    this.kind,
    this.parameters,
  });

  Map<String, dynamic> toMap() {
    return {
      'storageLimit': storageLimit,
      'amount': amount,
      'destination': destination,
      'kind': kind,
      'parameters': parameters,
    };
  }

  factory OperationDetails.fromMap(Map<String, dynamic> map) {
    return OperationDetails(
      storageLimit: map['storageLimit'],
      amount: map['amount'],
      destination: map['destination'],
      kind: map['kind'],
      parameters: map['parameters'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OperationDetails.fromJson(String source) => OperationDetails.fromMap(json.decode(source));
}

class PermissionTezosRequest implements BlockchainTezosRequest {
  //Map? appMetadata;
  AppMetadata? appMetadata;
  Map? origin;
  Map? network;
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

  PermissionTezosRequest(
      {required this.id,
      required this.blockchainIdentifier,
      required this.type,
      required this.senderId,
      required this.version,
      this.appMetadata,
      this.origin,
      this.network,
      this.scopes})
      : super();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockchainIdentifier': blockchainIdentifier,
      'type': type,
      'senderId': senderId,
      'version': version,
      'appMetadata': appMetadata!.toMap(),
      'origin': origin,
      'network': network,
      'scopes': scopes,
    };
  }

  factory PermissionTezosRequest.fromMap(Map<String, dynamic> map) {
    return PermissionTezosRequest(
      id: map['id'],
      blockchainIdentifier: map['blockchainIdentifier'],
      type: map['type'],
      senderId: map['senderId'],
      version: map['version'],
      appMetadata: map['appMetadata'] != null ? AppMetadata.fromMap(map['appMetadata']) : null,
      origin: map['origin'],
      network: map['network'],
      scopes: map['scopes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PermissionTezosRequest.fromJson(String source) => PermissionTezosRequest.fromMap(json.decode(source));
}

class OperationTezosRequest implements BlockchainTezosRequest {
  //Map? appMetadata;
  AppMetadata? appMetadata;
  Map? origin;
  Map? network;
  List<dynamic>? operationDetails;

  String? sourceAddress;

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

  OperationTezosRequest(
      {required this.id,
      required this.blockchainIdentifier,
      required this.type,
      required this.senderId,
      required this.version,
      this.appMetadata,
      this.origin,
      this.network,
      this.operationDetails,
      this.sourceAddress})
      : super();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockchainIdentifier': blockchainIdentifier,
      'type': type,
      'senderId': senderId,
      'version': version,
      'appMetadata': appMetadata!.toMap(),
      'origin': origin,
      'network': network,
      'operationDetails': operationDetails,
      'sourceAddress': sourceAddress,
    };
  }

  factory OperationTezosRequest.fromMap(Map<String, dynamic> map) {
    return OperationTezosRequest(
      id: map['id'],
      blockchainIdentifier: map['blockchainIdentifier'],
      type: map['type'],
      senderId: map['senderId'],
      version: map['version'],
      appMetadata: map['appMetadata'] != null ? AppMetadata.fromMap(map['appMetadata']) : null,
      origin: map['origin'],
      network: map['network'],
      operationDetails: map['operationDetails'],
      sourceAddress: map['sourceAddress'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OperationTezosRequest.fromJson(String source) => OperationTezosRequest.fromMap(json.decode(source));
}

class SignPayloadTezosRequest implements BlockchainTezosRequest {
  //Map? appMetadata;
  AppMetadata? appMetadata;
  Map? origin;
  Map? network;

  String? signingType;
  String? payload;
  String? sourceAddress;

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

  SignPayloadTezosRequest(
      {required this.id,
      required this.blockchainIdentifier,
      required this.type,
      required this.senderId,
      required this.version,
      this.appMetadata,
      this.origin,
      this.network,
      this.signingType,
      this.payload,
      this.sourceAddress})
      : super();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockchainIdentifier': blockchainIdentifier,
      'type': type,
      'senderId': senderId,
      'version': version,
      'appMetadata': appMetadata!.toMap(),
      'origin': origin,
      'network': network,
      'signingType': signingType,
      'payload': payload,
      'sourceAddress': sourceAddress,
    };
  }

  factory SignPayloadTezosRequest.fromMap(Map<String, dynamic> map) {
    return SignPayloadTezosRequest(
      id: map['id'],
      blockchainIdentifier: map['blockchainIdentifier'],
      type: map['type'],
      senderId: map['senderId'],
      version: map['version'],
      appMetadata: map['appMetadata'] != null ? AppMetadata.fromMap(map['appMetadata']) : null,
      origin: map['origin'],
      network: map['network'],
      signingType: map['signingType'],
      payload: map['payload'],
      sourceAddress: map['sourceAddress'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SignPayloadTezosRequest.fromJson(String source) => SignPayloadTezosRequest.fromMap(json.decode(source));
}

class BroadcastTezosRequest implements BlockchainTezosRequest {
  //Map? appMetadata;
  AppMetadata? appMetadata;
  Map? origin;
  Map? network;

  String? accountId;
  String? signedTransaction;

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

  BroadcastTezosRequest(
      {required this.id,
      required this.blockchainIdentifier,
      required this.type,
      required this.senderId,
      required this.version,
      this.appMetadata,
      this.origin,
      this.network,
      this.accountId,
      this.signedTransaction})
      : super();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockchainIdentifier': blockchainIdentifier,
      'type': type,
      'senderId': senderId,
      'version': version,
      'appMetadata': appMetadata!.toMap(),
      'origin': origin,
      'network': network,
      'accountId': accountId,
      'signedTransaction': signedTransaction
    };
  }

  factory BroadcastTezosRequest.fromMap(Map<String, dynamic> map) {
    return BroadcastTezosRequest(
        id: map['id'],
        blockchainIdentifier: map['blockchainIdentifier'],
        type: map['type'],
        senderId: map['senderId'],
        version: map['version'],
        appMetadata: map['appMetadata'] != null ? AppMetadata.fromMap(map['appMetadata']) : null,
        origin: map['origin'],
        network: map['network'],
        accountId: map['accountId'],
        signedTransaction: map['signedTransaction']);
  }

  String toJson() => json.encode(toMap());

  factory BroadcastTezosRequest.fromJson(String source) => BroadcastTezosRequest.fromMap(json.decode(source));
}

// {
//     "type": "tezos_sign_payload_request",
//     "id": "c08326b2-d0a4-6423-9cf9-2a33521f4d45",
//     "version": "2",
//     "blockchainIdentifier": "tezos",
//     "senderId": "2GvLDwaiiu1qx",
//     "appMetadata": {
//         "senderId": "2GvLDwaiiu1qx",
//         "name": "Rarible",
//         "blockchainIdentifier": "tezos"
//     },
//     "origin": {
//         "type": "p2p",
//         "id": "fef612074b86bf4d7bfb3b290f19d861b71d790e6597431435b78b65fe89218f"
//     },
//     "signingType": "micheline",
//     "payload": "0501000000dd54657a6f73205369676e6564204d6573736167653a2072617269626c652e636f6d20323032322d30362d30385431363a30303a34312e3838375a20492077616e7420746f206c6f67696e206f6e2052617269626c6520617420323032322d30362d30385431363a30303a34312e3835335a2e204920616363657074207468652052617269626c65205465726d73206f6620536572766963652068747470733a2f2f7374617469632e72617269626c652e636f6d2f7465726d732e70646620616e64204920616d206174206c65617374203133207965617273206f6c642e",
//     "sourceAddress": "tz1gWynSeB46Hb1j1QRq5SrsV6WLk3HZ7G5g"
// }

// {
//     "type": "tezos_permission_request",
//     "id": "da3b5cf2-90b5-4a55-7aae-92aacd00375e",
//     "version": "2",
//     "blockchainIdentifier": "tezos",
//     "senderId": "23QQgSvWM9CTv",
//     "appMetadata": {
//         "senderId": "23QQgSvWM9CTv",
//         "name": "objkt.com",
//         "icon": "https://assets.objkt.media/file/assets-002/objkt/objkt-logo.png",
//         "blockchainIdentifier": "tezos"
//     },
//     "origin": {
//         "type": "p2p",
//         "id": "fa3c00f2da741327ab92f323024d4c5775bd6544ad9a2a3d8cc2396876fe4574"
//     },
//     "network": {
//         "type": "mainnet"
//     },
//     "scopes": [
//         "operation_request",
//         "sign"
//     ]
// }

// {
//     "type": "tezos_operation_request",
//     "id": "73b43e1c-4ed3-ea7e-dada-f3b61ab347bc",
//     "version": "2",
//     "blockchainIdentifier": "tezos",
//     "senderId": "gbZAyj9eWYe5",
//     "appMetadata": {
//         "senderId": "gbZAyj9eWYe5",
//         "name": "objkt.com",
//         "icon": "https://assets.objkt.media/file/assets-002/objkt/objkt-logo.png",
//         "blockchainIdentifier": "tezos"
//     },
//     "origin": {
//         "type": "p2p",
//         "id": "4e025cb9fd24dea5f9fcf62022eef8fe0a1e23ad569414c26b74b2a58473bed0"
//     },
//     "network": {
//         "type": "mainnet"
//     },
//     "operationDetails": [
//         {
//             "storage_limit": "350",
//             "amount": "50000000",
//             "destination": "KT1WvzYHCNBvDSdwafTHv7nJ1dWmZ8GCYuuC",
//             "parameters": {
//                 "entrypoint": "fulfill_ask",
//                 "value": {
//                     "prim": "Pair",
//                     "args": [
//                         {
//                             "int": "1531633"
//                         },
//                         {
//                             "prim": "None"
//                         }
//                     ]
//                 }
//             },
//             "kind": "transaction"
//         }
//     ],
//     "sourceAddress": "tz1N6Dqo9PuWga38GjdfPXg1aSowbymWinGK"
// }