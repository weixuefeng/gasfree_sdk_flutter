import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:pointycastle/digests/keccak.dart';
import 'package:bs58check/bs58check.dart' as bs58;

// Re-export hex for convenience
export 'package:convert/convert.dart' show hex;

import 'types.dart';

// ---------------------------------------------------------------------------
// Keccak-256
// ---------------------------------------------------------------------------

/// Compute Keccak-256 hash.
Uint8List keccak256(Uint8List input) {
  final digest = KeccakDigest(256);
  return digest.process(input);
}

// ---------------------------------------------------------------------------
// Hex encoding / decoding
// ---------------------------------------------------------------------------

/// Convert bytes to hex string with 0x prefix.
String bytesToHex(Uint8List bytes) {
  return '0x${hex.encode(bytes)}';
}

/// Convert hex string (with or without 0x prefix) to bytes.
Uint8List hexToBytes(String hexStr) {
  hexStr = hexStr.replaceFirst('0x', '');
  if (hexStr.length % 2 != 0) {
    hexStr = '0$hexStr';
  }
  return Uint8List.fromList(hex.decode(hexStr));
}

/// Convert a hex string (or Buffer-compatible value) to bytes.
/// Compatible with JS `toBuffer()` semantics.
Uint8List toBuffer(dynamic value) {
  if (value is Uint8List) return value;
  if (value is String) return hexToBytes(value);
  if (value is int) {
    // Encode as big-endian uint256 (32 bytes)
    final big = BigInt.from(value);
    return _bigIntToUint8List(big, 32);
  }
  throw ArgumentError('Cannot convert $value to buffer');
}

/// Convert a Uint8List to hex string (without 0x prefix).
/// Compatible with JS `bufferToHex()`.
String bufferToHex(Uint8List buffer) {
  return bytesToHex(buffer);
}

Uint8List _bigIntToUint8List(BigInt value, int length) {
  final result = Uint8List(length);
  for (int i = length - 1; i >= 0; i--) {
    result[i] = (value & BigInt.from(0xff)).toInt();
    value = value >> 8;
  }
  return result;
}


// ---------------------------------------------------------------------------
// EIP-55 checksum address
// ---------------------------------------------------------------------------

/// Convert an address to EIP-55 mixed-case checksum format.
String toChecksumAddress(String address) {
  address = address.replaceFirst('0x', '').toLowerCase();
  final hash = bytesToHex(keccak256(utf8.encode(address))).replaceFirst('0x', '');
  final checksummed = StringBuffer('0x');
  for (var i = 0; i < address.length; i++) {
    if (int.parse(hash[i], radix: 16) >= 8) {
      checksummed.write(address[i].toUpperCase());
    } else {
      checksummed.write(address[i]);
    }
  }
  return checksummed.toString();
}

/// Check if a string is a valid EIP-55 checksummed address.
bool isValidChecksumAddress(String address) {
  if (!address.startsWith('0x') || address.length != 42) return false;
  return address == toChecksumAddress(address);
}

// ---------------------------------------------------------------------------
// TRON address utilities
// ---------------------------------------------------------------------------

/// TRON address prefix byte for mainnet.
const int tronAddressPrefix = 0x41;

/// Convert a TRON base58 address to an EVM hex address (with EIP-55 checksum).
EvmAddress toEthAddress(String tronAddress) {
  // Decode base58check
  final decoded = bs58.decode(tronAddress);
  if (decoded.isEmpty) {
    throw ArgumentError('Invalid TRON address: $tronAddress');
  }
  // First byte is the version prefix (0x41 for TRON)
  // Remaining 20 bytes are the actual address
  final addressBytes = decoded.sublist(1);
  if (addressBytes.length != 20) {
    throw ArgumentError('Invalid TRON address length: ${addressBytes.length}');
  }
  final hexAddress = bytesToHex(addressBytes);
  return toChecksumAddress(hexAddress);
}

/// Convert an EVM hex address to a TRON base58 address.
TronAddress ethToTronAddress(String evmAddress) {
  // Remove 0x prefix and pad to 40 hex chars (20 bytes)
  var clean = evmAddress.replaceFirst('0x', '');
  if (clean.length != 40) {
    throw ArgumentError('Invalid EVM address length: ${clean.length}');
  }
  // Prepend TRON prefix byte (0x41)
  final addressBytes = Uint8List.fromList([
    tronAddressPrefix,
    ...hexToBytes(clean),
  ]);
  // Base58Check encode
  return bs58.encode(addressBytes);
}

/// Check if a string is a valid TRON address (starts with T, 34 chars, valid base58check).
bool isValidTronAddress(String address) {
  if (!address.startsWith('T') || address.length != 34) return false;
  try {
    bs58.decode(address);
    return true;
  } catch (_) {
    return false;
  }
}

/// Check if a string is a valid EVM address (0x-prefixed, 42 chars, valid EIP-55 checksum).
bool isValidEvmAddress(String address) {
  if (!address.startsWith('0x') || address.length != 42) return false;
  // Accept either checksummed or all-lowercase/all-uppercase
  if (address == address.toLowerCase() || address == address.toUpperCase()) {
    return true;
  }
  return isValidChecksumAddress(address);
}

// ---------------------------------------------------------------------------
// Minimal ABI encoder (for calculateBytecodeHash)
// ---------------------------------------------------------------------------

/// ABI-encode a value according to its Solidity type.
/// Returns the encoded bytes, padded to 32 bytes for static types.
Uint8List abiEncode(String type, dynamic value) {
  switch (type) {
    case 'address':
      final addr = (value as String).replaceFirst('0x', '').padLeft(40, '0');
      return Uint8List.fromList(
        List.filled(12, 0) + hexToBytes(addr),
      );
    case 'bytes':
      return abiEncodeBytes(value);
    default:
      throw ArgumentError('Unsupported ABI type: $type');
  }
}

/// ABI-encode a dynamic bytes value (without offset — offset is managed by abiRawEncode).
/// Returns [length (32 bytes)] + [data (padded to 32 bytes)].
Uint8List abiEncodeBytes(dynamic value) {
  final data = value is Uint8List ? value : hexToBytes(value as String);
  final paddedLen = ((data.length + 31) ~/ 32) * 32;
  final padded = Uint8List(paddedLen);
  padded.setAll(0, data);

  final result = Uint8List(32 + paddedLen);
  // Length of the actual data (not padded)
  result.setAll(0, _bigIntToUint8List(BigInt.from(data.length), 32));
  // Padded data
  result.setAll(32, padded);
  return result;
}

/// ABI-encode a tuple of types.
/// Similar to ethereumjs-abi's `rawEncode(types, values)`.
Uint8List abiRawEncode(List<String> types, List<dynamic> values) {
  if (types.length != values.length) {
    throw ArgumentError('Types and values length mismatch');
  }

  final result = <int>[];
  final dynamicParts = <Uint8List>[];

  for (var i = 0; i < types.length; i++) {
    if (types[i] == 'bytes' || types[i] == 'string') {
      // Dynamic type - write a placeholder offset
      result.addAll(Uint8List(32));
      dynamicParts.add(abiEncode(types[i], values[i]));
    } else {
      result.addAll(abiEncode(types[i], values[i]));
    }
  }

  // Fill in dynamic offsets and append dynamic data
  var offset = result.length;
  var dynIdx = 0;
  for (var i = 0; i < types.length; i++) {
    if (types[i] == 'bytes' || types[i] == 'string') {
      // Write the offset at the placeholder position
      final placeholderStart = i * 32;
      final offsetBytes = _bigIntToUint8List(BigInt.from(offset), 32);
      result.setRange(placeholderStart, placeholderStart + 32, offsetBytes);
      result.addAll(dynamicParts[dynIdx]);
      offset += dynamicParts[dynIdx].length;
      dynIdx++;
    }
  }

  return Uint8List.fromList(result);
}

// ---------------------------------------------------------------------------
// General helpers
// ---------------------------------------------------------------------------

/// Check if a value is not null.
bool isDef(dynamic val) {
  return val != null;
}

/// Left-pad a number string to the specified length with zeros.
String padLeft(String s, int length, [String padding = '0']) {
  return s.padLeft(length, padding);
}
