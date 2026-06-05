import 'dart:convert';

import 'package:test/test.dart';
import 'package:gasfree_sdk_flutter/src/utils.dart';

void main() {
  group('test tron_to_eth_address', () {
    test('test tron address situation', () {
      const tronAddress = 'TWrmALWKr7wsDQBpBoX2WGEPSSqHcUqeHo';
      final ethAddress = toEthAddress(tronAddress);
      expect(ethAddress, equals('0xe52293550118e61Dc99A79F0043A55Ce7B9F178a'));

      // Double conversion (EVM -> TRON -> EVM should preserve)
      final dulEthAddress = toEthAddress(ethToTronAddress(ethAddress));
      expect(dulEthAddress, equals(ethAddress));
    });

    test('test eth_to_tron_address', () {
      const ethAddress = '0xe52293550118e61Dc99A79F0043A55Ce7B9F178a';
      final tronAddress = ethToTronAddress(ethAddress);
      expect(tronAddress, equals('TWrmALWKr7wsDQBpBoX2WGEPSSqHcUqeHo'));
    });

    test('test keccak256 produces consistent hash', () {
      final hash = keccak256(utf8.encode('hello'));
      final hashHex = bytesToHex(hash);
      // Known keccak256 hash of "hello"
      expect(hashHex,
          equals('0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8'));
    });
  });

  group('test address validation', () {
    test('test isValidTronAddress', () {
      expect(isValidTronAddress('TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC'), isTrue);
      expect(isValidTronAddress('invalid'), isFalse);
      expect(isValidTronAddress('0x1234'), isFalse);
    });

    test('test isValidEvmAddress', () {
      expect(isValidEvmAddress('0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf'), isTrue);
      expect(isValidEvmAddress('invalid'), isFalse);
    });
  });

  group('test hex encoding', () {
    test('test bytesToHex and hexToBytes roundtrip', () {
      final original = '0xdeadbeef';
      final bytes = hexToBytes(original);
      final result = bytesToHex(bytes);
      expect(result, equals(original));
    });

    test('test toBuffer and bufferToHex roundtrip', () {
      final original = '0x1234';
      final buf = toBuffer(original);
      final result = bufferToHex(buf);
      expect(result, equals(original));
    });
  });
}
