import 'gas_free.dart';
import 'types.dart';
import 'utils.dart';

/// EVM-compatible chain implementation of GasFree SDK.
///
/// Works with standard Ethereum-compatible chains (0x-prefixed addresses).
class EvmGasFree extends GasFree {
  EvmGasFree(super.parameter);

  @override
  bool checkIsValidAddress(String address) {
    if (address.isEmpty) return false;
    return isValidEvmAddress(address);
  }

  @override
  bool checkIsValidGasFreeTypedDataParams({required GasFreeTypedDataMessage message}) {
    if (!checkIsValidAddress(message.token)) {
      throw ArgumentError('Invalid message.token: ${message.token}');
    }
    if (!checkIsValidAddress(message.serviceProvider)) {
      throw ArgumentError('Invalid message.serviceProvider: ${message.serviceProvider}');
    }
    if (!checkIsValidAddress(message.user)) {
      throw ArgumentError('Invalid message.user: ${message.user}');
    }
    if (!checkIsValidAddress(message.receiver)) {
      throw ArgumentError('Invalid message.receiver: ${message.receiver}');
    }
    return true;
  }

  @override
  String getCreate2PrefixByte() {
    return '0xff';
  }

  @override
  String generateGasFreeAddress(String userAddress) {
    if (!isValidEvmAddress(userAddress)) {
      throw ArgumentError('Invalid user address: $userAddress');
    }

    final salt = calculateSalt(userAddress);
    final bytecodeHash = calculateBytecodeHash(
      userAddress,
      chainInfo.beacon,
      chainInfo.creationCode,
    );

    return calculateCreate2Address(salt, bytecodeHash, chainInfo.gasFreeController);
  }
}