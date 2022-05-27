import 'dart:convert';

abstract class BlockchainTezosReponse {
  @override
  String? id;
  @override
  String? version;
}

class OperationTezosResponse extends BlockchainTezosReponse {
  @override
  String? id;
  @override
  String blockchainIdentifier;
  String transactionHash;
  String requestOrigin;
  @override
  String? version = "1";

  OperationTezosResponse({
    required this.id,
    required this.transactionHash,
    required this.blockchainIdentifier,
    required this.requestOrigin,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionHash': transactionHash,
      'blockchainIdentifier': blockchainIdentifier,
      'requestOrigin': requestOrigin,
      'version': version,
    };
  }

  factory OperationTezosResponse.fromMap(Map<String, dynamic> map) {
    return OperationTezosResponse(
      id: map['id'],
      transactionHash: map['transactionHash'],
      blockchainIdentifier: map['blockchainIdentifier'],
      requestOrigin: map['requestOrigin'],
      version: map['version'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OperationTezosResponse.fromJson(String source) => OperationTezosResponse.fromMap(json.decode(source));
}
