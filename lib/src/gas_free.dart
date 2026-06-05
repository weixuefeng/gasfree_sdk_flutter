import 'dart:convert';
import 'dart:typed_data';

import 'constants/common.dart';
import 'types.dart';
import 'utils.dart';

/// GasFree parameter either requires [chainId] or [chainInfo] (exactly one).
class GasFreeParameter {
  final int? chainId;
  final ChainInfo? chainInfo;

  const GasFreeParameter({this.chainId, this.chainInfo});
}

/// Abstract base class for GasFree SDK.
///
/// Provides core functionality for:
/// - GasFree address generation (CREATE2-based)
/// - EIP-712 typed data assembly for PermitTransfer
/// - Ledger raw hash generation
///
/// Subclasses must implement chain-specific address validation and formatting.
abstract class GasFree {
  /// The resolved chain info for this instance.
  final ChainInfo chainInfo;

  /// Validator for message typed data.
  final String? Function(GasFreeTypedDataMessage)? messageValidator;

  /// Constructor. Requires exactly one of [chainId] or [chainInfo].
  GasFree(GasFreeParameter parameter, {this.messageValidator})
      : chainInfo = _resolveChainInfo(parameter);

  static ChainInfo _resolveChainInfo(GasFreeParameter parameter) {
    final hasChainId = isDef(parameter.chainId);
    final hasChainInfo = isDef(parameter.chainInfo);

    if ((hasChainId && hasChainInfo) || (!hasChainId && !hasChainInfo)) {
      throw ArgumentError(
        'Invalid arguments provided. This function requires exactly one argument: '
        'either chainId or chainInfo, but not both.',
      );
    }

    if (hasChainId) {
      if (!_checkIsValidChainId(parameter.chainId)) {
        throw ArgumentError('Invalid chainId: ${parameter.chainId}');
      }
      final defaultChainInfo = defaultChainInfoMap[parameter.chainId];
      if (defaultChainInfo == null) {
        throw ArgumentError('Invalid chainId: ${parameter.chainId}');
      }
      return defaultChainInfo;
    } else {
      final info = parameter.chainInfo!;
      if (!_checkIsValidChainId(info.chainId)) {
        throw ArgumentError('Invalid chainId: ${info.chainId}');
      }
      if (!_checkIsValidAddressCore(info.gasFreeController)) {
        throw ArgumentError('Invalid gasFreeController: ${info.gasFreeController}');
      }
      if (!_checkIsValidAddressCore(info.beacon)) {
        throw ArgumentError('Invalid beacon: ${info.beacon}');
      }
      if (!_checkIsValidCreationCode(info.creationCode)) {
        throw ArgumentError('Invalid creationCode');
      }
      return info;
    }
  }

  static bool _checkIsValidChainId(int? chainId) {
    if (chainId == null) return false;
    if (chainId <= 0) return false;
    const maxChainId = 0xffffffff;
    if (chainId > maxChainId) return false;
    return true;
  }

  static bool _checkIsValidAddressCore(String? address) {
    if (address == null || address.isEmpty) return false;
    // Basic check: must be non-empty string
    return true;
  }

  static bool _checkIsValidCreationCode(String? creationCode) {
    if (creationCode == null || creationCode.isEmpty) return false;
    try {
      var hex = creationCode.startsWith('0x') ? creationCode.substring(2) : creationCode;
      if (!RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex)) return false;
      if (hex.length % 2 != 0) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Check if a number string is a valid non-negative integer.
  bool checkIsValidMessageNumber(String value) {
    try {
      final bigIntNum = BigInt.parse(value);
      if (bigIntNum < BigInt.zero) return false;
    } catch (_) {
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // EIP-712 typed data assembly
  // ---------------------------------------------------------------------------

  /// Assemble a standard EIP-712 GasFree transaction JSON (EVM format).
  EvmGasFreeTypedData assembleStandard712GasFreeTransactionJson(
    AssembleGasFreeTransactionParams params,
  ) {
    _validateAddress(params.token, 'token');
    _validateAddress(params.serviceProvider, 'serviceProvider');
    _validateAddress(params.user, 'user');
    _validateAddress(params.receiver, 'receiver');

    // value and maxFee are already typed as String in Dart

    if (!checkIsValidMessageNumber(params.value)) {
      throw ArgumentError('Invalid value: ${params.value}');
    }
    if (!checkIsValidMessageNumber(params.maxFee)) {
      throw ArgumentError('Invalid maxFee: ${params.maxFee}');
    }
    if (!checkIsValidMessageNumber(params.deadline)) {
      throw ArgumentError('Invalid deadline: ${params.deadline}');
    }
    if (!checkIsValidMessageNumber(params.version)) {
      throw ArgumentError('Invalid version: ${params.version}');
    }
    if (!checkIsValidMessageNumber(params.nonce)) {
      throw ArgumentError('Invalid nonce: ${params.nonce}');
    }

    final domain = getGasFreeTypedDataDomain();

    final types = <String, List<Eip712TypeField>>{
      'PermitTransfer': permitTransferType,
      'EIP712Domain': eip712DomainType,
    };

    final message = GasFreeTypedDataMessage(
      token: toEthAddress(params.token),
      serviceProvider: toEthAddress(params.serviceProvider),
      user: toEthAddress(params.user),
      receiver: toEthAddress(params.receiver),
      value: params.value,
      maxFee: params.maxFee,
      deadline: params.deadline,
      version: params.version,
      nonce: params.nonce,
    );

    return EvmGasFreeTypedData(
      types: types,
      domain: domain,
      message: message,
      primaryType: 'PermitTransfer',
    );
  }

  void _validateAddress(String address, String fieldName) {
    if (!checkIsValidAddress(address)) {
      throw ArgumentError('Invalid $fieldName: $address');
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE2 address computation
  // ---------------------------------------------------------------------------

  /// Compute the CREATE2 salt for a given address.
  /// The salt is the address padded to 32 bytes (64 hex chars), right-aligned.
  String calculateSalt(String address) {
    if (!checkIsValidAddress(address)) {
      throw ArgumentError('Invalid address: $address');
    }
    final ethAddr = toEthAddress(address);
    final hexAddr = ethAddr.replaceFirst('0x', '');
    return '0x${hexAddr.padLeft(64, '0')}';
  }

  /// Add the `initialize(address)` function selector to the given address.
  String addFunctionSelectorToAddress(String address) {
    if (!address.startsWith('0x') || address.length != 66) {
      throw ArgumentError('Invalid address format. Expected 0x-prefixed 66 chars (64 hex + 0x).');
    }
    const functionSignature = 'initialize(address)';
    final funcSelector =
        bytesToHex(keccak256(utf8.encode(functionSignature)).sublist(0, 4)).replaceFirst('0x', '');
    return '0x$funcSelector${address.substring(2)}';
  }

  /// Compute the bytecode hash for a CREATE2 deployment.
  String calculateBytecodeHash(String address, String beacon, String creationCode) {
    if (!checkIsValidAddress(address)) {
      throw ArgumentError('Invalid address: $address');
    }
    final initializeData = addFunctionSelectorToAddress(calculateSalt(address));
    final beaconAddress = toEthAddress(beacon);

    final abiEncoded = abiRawEncode(['address', 'bytes'], [
      beaconAddress,
      hexToBytes(initializeData),
    ]);

    final creationCodeBytes = hexToBytes(creationCode);
    final encodedData = Uint8List.fromList([...creationCodeBytes, ...abiEncoded]);

    return bytesToHex(keccak256(encodedData));
  }

  /// Compute a CREATE2 address.
  EvmAddress calculateCreate2Address(
    String salt,
    String bytecodeHash,
    String gasFreeController,
  ) {
    final gasFreeControllerHex = toEthAddress(gasFreeController);
    final prefixHex = getCreate2PrefixByte();

    final create2Input = Uint8List.fromList([
      ...hexToBytes(prefixHex),
      ...hexToBytes(gasFreeControllerHex),
      ...hexToBytes(salt),
      ...hexToBytes(bytecodeHash),
    ]);

    final hash = keccak256(create2Input);
    // Take last 20 bytes to form the address
    final addressBytes = hash.sublist(12);

    return toChecksumAddress(bytesToHex(addressBytes));
  }

  /// Compute the full GasFree contract address for a user.
  String calculateGasFreeContractAddress(
    String userAddress,
    String gasFreeController,
    String beacon,
    String creationCode,
  ) {
    if (!checkIsValidAddress(userAddress)) {
      throw ArgumentError('Invalid userAddress: $userAddress');
    }
    final salt = calculateSalt(userAddress);
    final bytecodeHash = calculateBytecodeHash(userAddress, beacon, creationCode);
    return calculateCreate2Address(salt, bytecodeHash, gasFreeController);
  }

  // ---------------------------------------------------------------------------
  // EIP-712 Ledger signing hash
  // ---------------------------------------------------------------------------

  /// Get the EIP-712 domain object for GasFree.
  Eip712Domain getGasFreeTypedDataDomain() {
    return Eip712Domain(
      name: 'GasFreeController',
      version: 'V1.0.0',
      chainId: chainInfo.chainId,
      verifyingContract: toEthAddress(chainInfo.gasFreeController),
    );
  }

  /// Compute the EIP-712 hash for Ledger hardware wallet signing.
  GasFreeLedgerRawHash getGasFreeLedgerRawHash({
    required GasFreeTypedDataMessage message,
  }) {
    final domain = getGasFreeTypedDataDomain();

    final eip712Types = <String, List<Eip712TypeField>>{
      'EIP712Domain': eip712DomainType,
      'PermitTransfer': permitTransferType,
    };

    final domainSeparatorHex = eip712HashStruct('EIP712Domain', _domainToMap(domain), eip712Types);
    final hashStructMessageHex =
        eip712HashStruct('PermitTransfer', _messageToMap(message), eip712Types);

    // EIP-712 signing: keccak256(0x1901 + domainSeparator + hashStructMessage)
    final permitTransferMessageHash = bytesToHex(keccak256(
      Uint8List.fromList([
        ...hexToBytes('0x1901'),
        ...hexToBytes(domainSeparatorHex),
        ...hexToBytes(hashStructMessageHex),
      ]),
    ));

    return GasFreeLedgerRawHash(
      domainSeparatorHex: domainSeparatorHex,
      hashStructMessageHex: hashStructMessageHex,
      permitTransferMessageHash: permitTransferMessageHash,
    );
  }

  // ---------------------------------------------------------------------------
  // EIP-712 encoding internals
  // ---------------------------------------------------------------------------

  /// Encode the EIP-712 type string.
  /// e.g., "PermitTransfer(address token,address serviceProvider,...,uint256 nonce)"
  String _eip712EncodeType(String primaryType, Map<String, List<Eip712TypeField>> types) {
    // Collect all dependent types (in definition order)
    final deps = <String>{primaryType};
    _collectDeps(primaryType, types, deps);

    final sortedDeps = deps.toList()
      ..sort((a, b) {
        if (a == primaryType) return -1;
        if (b == primaryType) return 1;
        return a.compareTo(b);
      });

    return sortedDeps.map((type) {
      final fields = types[type]!;
      final fieldStr = fields.map((f) => '${f.type} ${f.name}').join(',');
      return '$type($fieldStr)';
    }).join();
  }

  void _collectDeps(
    String type,
    Map<String, List<Eip712TypeField>> types,
    Set<String> deps,
  ) {
    for (final field in types[type] ?? []) {
      if (types.containsKey(field.type) && !deps.contains(field.type)) {
        deps.add(field.type);
        _collectDeps(field.type, types, deps);
      }
    }
  }

  /// Encode data for EIP-712 hashStruct.
  Uint8List _eip712EncodeData(
    String primaryType,
    Map<String, dynamic> data,
    Map<String, List<Eip712TypeField>> types,
  ) {
    final result = <int>[];
    final fields = types[primaryType]!;

    for (final field in fields) {
      final value = data[field.name];
      result.addAll(_eip712EncodeValue(field.type, value, types));
    }

    return Uint8List.fromList(result);
  }

  Uint8List _eip712EncodeValue(
    String type,
    dynamic value,
    Map<String, List<Eip712TypeField>> types,
  ) {
    if (type == 'string') {
      // keccak256(utf8(value))
      return keccak256(utf8.encode(value as String));
    } else if (type == 'bytes') {
      // keccak256(bytes)
      return keccak256(value is Uint8List ? value : hexToBytes(value as String));
    } else if (type == 'bool') {
      return Uint8List.fromList([...List.filled(31, 0), value ? 1 : 0]);
    } else if (type == 'address') {
      // Left-pad to 32 bytes
      final addr = (value as String).replaceFirst('0x', '').padLeft(64, '0');
      return hexToBytes(addr);
    } else if (type.startsWith('uint') || type.startsWith('int')) {
      // Encode as big-endian 32 bytes
      final bigIntVal = value is BigInt ? value : BigInt.parse(value.toString());
      return _bigIntTo32Bytes(bigIntVal);
    } else if (types.containsKey(type)) {
      // Reference type (struct) - recursively hash
      return keccak256(_eip712EncodeData(type, value as Map<String, dynamic>, types));
    }

    throw ArgumentError('Unsupported EIP-712 type: $type');
  }

  Uint8List _bigIntTo32Bytes(BigInt value) {
    final result = Uint8List(32);
    for (int i = 31; i >= 0; i--) {
      result[i] = (value & BigInt.from(0xff)).toInt();
      value = value >> 8;
    }
    return result;
  }

  /// Compute the EIP-712 hashStruct(type, data) = keccak256(typeHash || encodeData)
  String eip712HashStruct(
    String primaryType,
    Map<String, dynamic> data,
    Map<String, List<Eip712TypeField>> types,
  ) {
    final typeHash = keccak256(utf8.encode(_eip712EncodeType(primaryType, types)));
    final encodedData = _eip712EncodeData(primaryType, data, types);

    final combined = Uint8List.fromList([...typeHash, ...encodedData]);
    return bytesToHex(keccak256(combined));
  }

  Map<String, dynamic> _domainToMap(Eip712Domain domain) {
    return {
      'name': domain.name,
      'version': domain.version,
      'chainId': BigInt.from(domain.chainId),
      'verifyingContract': domain.verifyingContract,
    };
  }

  Map<String, dynamic> _messageToMap(GasFreeTypedDataMessage message) {
    return {
      'token': message.token,
      'serviceProvider': message.serviceProvider,
      'user': message.user,
      'receiver': message.receiver,
      'value': message.value,
      'maxFee': message.maxFee,
      'deadline': message.deadline,
      'version': message.version,
      'nonce': message.nonce,
    };
  }

  // ---------------------------------------------------------------------------
  // Abstract methods
  // ---------------------------------------------------------------------------

  /// Validate if the typed data message parameters are correct.
  bool checkIsValidGasFreeTypedDataParams({required GasFreeTypedDataMessage message});

  /// Validate if an address string is valid for this chain.
  bool checkIsValidAddress(String address);

  /// Get the CREATE2 prefix byte for this chain.
  /// Standard EVM: '0xff', TRON: '0x41'.
  String getCreate2PrefixByte();

  /// Generate a GasFree address for the given user address.
  String generateGasFreeAddress(String userAddress);
}
