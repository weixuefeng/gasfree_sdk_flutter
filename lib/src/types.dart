/// TRON address type (base58, starts with T)
typedef TronAddress = String;

/// EVM address type (hex, starts with 0x)
typedef EvmAddress = String;

/// Chain configuration
class ChainInfo {
  final int chainId;
  final String gasFreeController;
  final String beacon;
  final String creationCode;

  const ChainInfo({
    required this.chainId,
    required this.gasFreeController,
    required this.beacon,
    required this.creationCode,
  });

  Map<String, dynamic> toJson() => {
        'chainId': chainId,
        'gasFreeController': gasFreeController,
        'beacon': beacon,
        'creationCode': creationCode,
      };
}

/// The message parameters for a GasFree transfer (EIP-712 PermitTransfer)
class GasFreeTypedDataMessage {
  final String token;
  final String serviceProvider;
  final String user;
  final String receiver;
  final String value;
  final String maxFee;
  final String deadline;
  final String version;
  final String nonce;

  const GasFreeTypedDataMessage({
    required this.token,
    required this.serviceProvider,
    required this.user,
    required this.receiver,
    required this.value,
    required this.maxFee,
    required this.deadline,
    required this.version,
    required this.nonce,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'serviceProvider': serviceProvider,
        'user': user,
        'receiver': receiver,
        'value': value,
        'maxFee': maxFee,
        'deadline': deadline,
        'version': version,
        'nonce': nonce,
      };
}

/// An EIP-712 type field definition
class Eip712TypeField {
  final String name;
  final String type;

  const Eip712TypeField(this.name, this.type);

  Map<String, dynamic> toJson() => {'name': name, 'type': type};
}

/// EIP-712 domain data
class Eip712Domain {
  final String name;
  final String version;
  final int chainId;
  final String verifyingContract;

  const Eip712Domain({
    required this.name,
    required this.version,
    required this.chainId,
    required this.verifyingContract,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'chainId': chainId,
        'verifyingContract': verifyingContract,
      };
}

/// The full EIP-712 typed data (EVM standard format)
class EvmGasFreeTypedData {
  final Map<String, List<Eip712TypeField>> types;
  final Eip712Domain domain;
  final GasFreeTypedDataMessage message;
  final String primaryType;

  const EvmGasFreeTypedData({
    required this.types,
    required this.domain,
    required this.message,
    this.primaryType = 'PermitTransfer',
  });

  Map<String, dynamic> toJson() => {
        'types': types.map((k, v) => MapEntry(k, v.map((f) => f.toJson()).toList())),
        'domain': domain.toJson(),
        'message': message.toJson(),
        'primaryType': primaryType,
      };
}

/// TRON-specific EIP-712 typed data (addresses are TRON base58 format)
class TronGasFreeTypedData {
  final Map<String, List<Eip712TypeField>> types;
  final Eip712Domain domain;
  final GasFreeTypedDataMessage message;

  const TronGasFreeTypedData({
    required this.types,
    required this.domain,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
        'types': types.map((k, v) => MapEntry(k, v.map((f) => f.toJson()).toList())),
        'domain': domain.toJson(),
        'message': message.toJson(),
      };
}

/// Result of computing the Ledger raw hash
class GasFreeLedgerRawHash {
  final String domainSeparatorHex;
  final String hashStructMessageHex;
  final String permitTransferMessageHash;

  const GasFreeLedgerRawHash({
    required this.domainSeparatorHex,
    required this.hashStructMessageHex,
    required this.permitTransferMessageHash,
  });
}

/// Parameters for assembling a GasFree transaction
class AssembleGasFreeTransactionParams {
  final String token;
  final String serviceProvider;
  final String user;
  final String receiver;
  final String value;
  final String maxFee;
  final String deadline;
  final String version;
  final String nonce;

  const AssembleGasFreeTransactionParams({
    required this.token,
    required this.serviceProvider,
    required this.user,
    required this.receiver,
    required this.value,
    required this.maxFee,
    required this.deadline,
    required this.version,
    required this.nonce,
  });

}
