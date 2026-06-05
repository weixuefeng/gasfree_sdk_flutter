import 'constants/common.dart';
import 'constants/schema.dart';
import 'gas_free.dart';
import 'types.dart';
import 'utils.dart';

/// TRON-specific implementation of GasFree SDK.
///
/// Handles TRON base58 addresses and chain-specific CREATE2 prefix.
class TronGasFree extends GasFree {
  TronGasFree(super.parameter);

  @override
  bool checkIsValidAddress(String address) {
    if (address.isEmpty) return false;
    return isValidTronAddress(address) || isValidEvmAddress(address);
  }

  @override
  bool checkIsValidGasFreeTypedDataParams({required GasFreeTypedDataMessage message}) {
    final validationError = validateMessage(message);
    if (validationError != null) {
      throw ArgumentError('Invalid input message: $validationError');
    }

    if (!isValidTronAddress(message.token)) {
      throw ArgumentError('Invalid message.token: ${message.token}, should be a valid Tron address');
    }
    if (!isValidTronAddress(message.user)) {
      throw ArgumentError('Invalid message.user: ${message.user}, should be a valid Tron address');
    }
    if (!isValidTronAddress(message.receiver)) {
      throw ArgumentError('Invalid message.receiver: ${message.receiver}, should be a valid Tron address');
    }
    if (!isValidTronAddress(message.serviceProvider)) {
      throw ArgumentError('Invalid message.serviceProvider: ${message.serviceProvider}, should be a valid Tron address');
    }

    return true;
  }

  @override
  String getCreate2PrefixByte() {
    return '0x41';
  }

  @override
  String generateGasFreeAddress(String userAddress) {
    if (!isValidTronAddress(userAddress)) {
      throw ArgumentError('Invalid user address: $userAddress');
    }

    final salt = calculateSalt(userAddress);
    final bytecodeHash = calculateBytecodeHash(
      userAddress,
      chainInfo.beacon,
      chainInfo.creationCode,
    );
    print('bytecodeHash is: ${bytecodeHash}');
    return ethToTronAddress(
      calculateCreate2Address(salt, bytecodeHash, chainInfo.gasFreeController),
    );
  }

  /// Assemble a TRON-specific GasFree transaction JSON (addresses in base58 format).
  TronGasFreeTypedData assembleGasFreeTransactionJson(
    AssembleGasFreeTransactionParams parameters,
  ) {
    final evmData = super.assembleStandard712GasFreeTransactionJson(parameters);

    // Convert addresses back to TRON format
    final message = GasFreeTypedDataMessage(
      token: ethToTronAddress(evmData.message.token),
      serviceProvider: ethToTronAddress(evmData.message.serviceProvider),
      user: ethToTronAddress(evmData.message.user),
      receiver: ethToTronAddress(evmData.message.receiver),
      value: evmData.message.value,
      maxFee: evmData.message.maxFee,
      deadline: evmData.message.deadline,
      version: evmData.message.version,
      nonce: evmData.message.nonce,
    );

    final domain = Eip712Domain(
      name: evmData.domain.name,
      version: evmData.domain.version,
      chainId: evmData.domain.chainId,
      verifyingContract: ethToTronAddress(evmData.domain.verifyingContract),
    );

    return TronGasFreeTypedData(
      domain: domain,
      types: {'PermitTransfer': permitTransferType},
      message: message,
    );
  }
}