import 'package:test/test.dart';
import 'package:gasfree_sdk_flutter/src/constants/common.dart';
import 'package:gasfree_sdk_flutter/src/gas_free.dart';
import 'package:gasfree_sdk_flutter/src/tron_gas_free.dart';
import 'package:gasfree_sdk_flutter/src/types.dart';
import 'package:gasfree_sdk_flutter/src/utils.dart';

// ---------------------------------------------------------------------------
// Test constants (matching JS SDK test/constant.ts)
// ---------------------------------------------------------------------------

const nileChainId = TronChainId.nile;
final nileChainInfo = defaultChainInfoMap[TronChainId.nile.value]!;
const nileGasFreeController = 'THQGuFzL87ZqhxkgqYEryRAd7gqFqL5rdc';
const nileBeacon = 'TLtCGmaxH3PbuaF6kbybwteZcHptEdgQGC';
final nileCreationCode = defaultChainInfoMap[TronChainId.nile.value]!.creationCode;

// ---------------------------------------------------------------------------
// Test data (from JS SDK test constant.ts)
// ---------------------------------------------------------------------------

class _AddressTestData {
  final String user;
  final String gasFreeAddress;
  final String salt;
  final String bytecodeHash;
  const _AddressTestData({
    required this.user,
    required this.gasFreeAddress,
    required this.salt,
    required this.bytecodeHash,
  });
}

const _addressTestData = [
  _AddressTestData(
    user: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
    gasFreeAddress: 'TWbQCj2Ez16Tg5Bwzok6zTSTttb8tNmP3U',
    salt: '0x0000000000000000000000007E5F4552091A69125d5DfCb7b8C2659029395Bdf',
    bytecodeHash: '0x18a462e3c9b4f5b55e14e6ec9dfba074bc9bdaef53058cdab80a3f5e543da7cb',
  ),
  _AddressTestData(
    user: 'TDvSsdrNM5eeXNL3czpa6AxLDHZA9nwe9K',
    gasFreeAddress: 'TJvTsxCPem4JGovdj3D2ffn4g9fobveHsX',
    salt: '0x0000000000000000000000002B5AD5c4795c026514f8317c7a215E218DcCD6cF',
    bytecodeHash: '0x0293c2bdd97aa6c732d4331e53ed8a9c4e89eb004ba3397f1f3fa69f2c8901dc',
  ),
  _AddressTestData(
    user: 'TKTX96CBxr5kvhjsDHcqoiPWZageGxoTW3',
    gasFreeAddress: 'TBPA6GGqHGHhehu9jvksn29SC4iwG7sFJt',
    salt: '0x0000000000000000000000006813Eb9362372EEF6200f3b1dbC3f819671cBA69',
    bytecodeHash: '0x55f68fd5222a1b4bb20f2769aaaecf06fb14c914315d8c0d6eb7e09fa4b25ef2',
  ),
  _AddressTestData(
    user: 'TCo75zcxTuWn5nnFqZUeK5socdVnG11f2T',
    gasFreeAddress: 'TURgwyMXhqtZBdazWduUHKWBADBLPi1DVA',
    salt: '0x0000000000000000000000001efF47bc3a10a45D4B230B5d10E37751FE6AA718',
    bytecodeHash: '0x28bc5221263a6c4166433ca4daabbd6eb27ca3b34a776b991c45d8c4d959aeea',
  ),
  _AddressTestData(
    user: 'TWYSVbUy6eTu6ZrFWRUimgDy9SinkggVKL',
    gasFreeAddress: 'TUj4g117wEeetmgydS3Vy3tHsjLQSBFsMU',
    salt: '0x000000000000000000000000e1AB8145F7E55DC933d51a18c793F901A3A0b276',
    bytecodeHash: '0x583e7e5d89a96a05502ec5600b7e97c515cd6be5e88a591ba18bf31f247c68fa',
  ),
];

class _MessageTestData {
  final GasFreeTypedDataMessage message;
  final String encodeMessage;
  final String permitHash;
  const _MessageTestData({
    required this.message,
    required this.encodeMessage,
    required this.permitHash,
  });
}

// Build messages with EVM addresses (as used by the JS SDK Ledger hash tests)
final _messageTestData = [
  _MessageTestData(
    message: GasFreeTypedDataMessage(
      token: toEthAddress('TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf'),
      serviceProvider: toEthAddress('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'),
      user: toEthAddress('TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC'),
      receiver: toEthAddress('TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC'),
      value: '10000',
      maxFee: '2000',
      deadline: '1726207632',
      version: '1',
      nonce: '2',
    ),
    encodeMessage: '0x66ddee4970f99745397d1da5037b1af25380b406e58d613e9a4e44c88f53f656',
    permitHash: '0xb1226f3a0b690b04e2c39fac3b58352ed68943a12a54b58035045215aaf0b9b1',
  ),
  _MessageTestData(
    message: GasFreeTypedDataMessage(
      token: toEthAddress('TLBaRhANQoJFTqre9Nf1mjuwNWjCJeYqUL'),
      serviceProvider: toEthAddress('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'),
      user: toEthAddress('TDvSsdrNM5eeXNL3czpa6AxLDHZA9nwe9K'),
      receiver: toEthAddress('TLFXfejEMgivFDR2x8qBpukMXd56spmFhz'),
      value: '20000',
      maxFee: '2000',
      deadline: '1726507632',
      version: '1',
      nonce: '3',
    ),
    encodeMessage: '0x810698dcc75464432adbb9ee4f3cabeb8340e59b278df4a67799cedcbd4ff2eb',
    permitHash: '0x25c20423c18719438f4d40e6b8fec40ede6b73fb3fa702453ea9bd17dd154fb5',
  ),
  _MessageTestData(
    message: GasFreeTypedDataMessage(
      token: toEthAddress('TVSvjZdyDSNocHm7dP3jvCmMNsCnMTPa5W'),
      serviceProvider: toEthAddress('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'),
      user: toEthAddress('TKTX96CBxr5kvhjsDHcqoiPWZageGxoTW3'),
      receiver: toEthAddress('TX7WF4tRGQehC9W88XEEKBhQRkLmAtZqKo'),
      value: '100000',
      maxFee: '2000',
      deadline: '1729507632',
      version: '1',
      nonce: '5',
    ),
    encodeMessage: '0x2904790f034a8932b4098421c9a471b340a3801aaaab2e59a70498bb87d680d3',
    permitHash: '0x3d103a6a3407dfe7540696131d7cafc3d41d7d8649b93a95daeee041e66238ce',
  ),
  _MessageTestData(
    message: GasFreeTypedDataMessage(
      token: toEthAddress('TWrZRHY9aKQZcyjpovdH6qeCEyYZrRQDZt'),
      serviceProvider: toEthAddress('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'),
      user: toEthAddress('TCo75zcxTuWn5nnFqZUeK5socdVnG11f2T'),
      receiver: toEthAddress('TCN4biEVzzfyUgN1NM8iysp4bYx6mx2gPv'),
      value: '100000',
      maxFee: '2000',
      deadline: '1729517632',
      version: '1',
      nonce: '15',
    ),
    encodeMessage: '0x3bf2b313fb43ef51fd25ef50e2ea48471879d1f9db00fcac9b1e7b054e27779d',
    permitHash: '0xa1a612e946ad2fecc8bcd2f93f987c38a06ca4807db7af30442e9308a20234ea',
  ),
  _MessageTestData(
    message: GasFreeTypedDataMessage(
      token: toEthAddress('TDnDyfMigx5nch7cCrtzGSwTXkUBnQJ9Pg'),
      serviceProvider: toEthAddress('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'),
      user: toEthAddress('TWYSVbUy6eTu6ZrFWRUimgDy9SinkggVKL'),
      receiver: toEthAddress('TVkoisqxn1SbET8ztcnjqRGAY4npxqDcmv'),
      value: '100000',
      maxFee: '2000',
      deadline: '1729907632',
      version: '1',
      nonce: '50',
    ),
    encodeMessage: '0xa2d2ed284f8300560812505b7699d3f9fde3bafacd5444ca3de812705ff2ebbf',
    permitHash: '0xc78d11f0afc5397f9329861888a6724b66fe370f0189e67c39bfad4eeb7ec2a9',
  ),
];

// Expected domain separator for Nile chain
const _tronDomainSeparator =
    '0x31a0a46f427dd040c91835228e4555951bde0a894cae6239869bb680ebc6ebea';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('test init TronGasFree', () {
    test('should create instance with valid chainId', () {
      final tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
      expect(tronGasFree, isNotNull);
    });

    test('should generate mainnet chainInfo when mainnet chainId is provided', () {
      final tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.mainnet.value));
      final userAddress = 'TAQnMWybBtqWpYgRHfonKGCBWWDRsExKDe';
      final exceptAddress = 'TUafjnJzCFiKxYxzerE4iQyvC19kPUqvyc';
      final generatedAddress = tronGasFree.generateGasFreeAddress(userAddress);
      expect(generatedAddress, equals(exceptAddress));
    });

    test('should generate mainnet chainInfo when testnet chainId is provided', () {
      final tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
      final userAddress = 'TAQnMWybBtqWpYgRHfonKGCBWWDRsExKDe';
      final exceptAddress = 'TWKiUtgAQ2rZSKYuKeLapUgCrRFDKSG2qA';
      final generatedAddress = tronGasFree.generateGasFreeAddress(userAddress);
      expect(generatedAddress, equals(exceptAddress));
    });

    test('should generate mainnet chainInfo when shasta testnet chainId is provided', () {
      final tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.shasta.value));
      final userAddress = 'TAQnMWybBtqWpYgRHfonKGCBWWDRsExKDe';
      final exceptAddress = 'TVNiZuFQLHu9DiCt3aFFcbZcBYxJt4QXQA';
      final generatedAddress = tronGasFree.generateGasFreeAddress(userAddress);
      expect(generatedAddress, equals(exceptAddress));
    });

    test('should create instance with valid chainInfo', () {
      final validChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: nileCreationCode,
      );
      final tronGasFree = TronGasFree(GasFreeParameter(chainInfo: validChainInfo));
      expect(tronGasFree, isNotNull);
    });

    test('should throw error when invalid chainId (not in map)', () {
      expect(
        () => TronGasFree(GasFreeParameter(chainId: 122)),
        throwsArgumentError,
      );
    });

    test('should throw error when chainId exceeds max', () {
      expect(
        () => TronGasFree(GasFreeParameter(chainId: 0xfffffffffff)),
        throwsArgumentError,
      );
    });

    test('should throw error when neither chainId nor chainInfo is provided', () {
      expect(
        () => TronGasFree(GasFreeParameter()),
        throwsArgumentError,
      );
    });

    test('should throw error when invalid gasFreeController', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: '',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: nileCreationCode,
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when invalid beacon', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: '',
        creationCode: nileCreationCode,
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when chainId is 0', () {
      final invalidChainInfo = ChainInfo(
        chainId: 0,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: nileCreationCode,
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when invalid creationCode (empty)', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: '',
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when invalid hex creationCode', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: 'abcdefg',
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when odd-length creationCode', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: '1111111',
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });

    test('should throw error when short creationCode (0x000)', () {
      final invalidChainInfo = ChainInfo(
        chainId: TronChainId.nile.value,
        gasFreeController: 'TSKUEvoSL84jQMKMuCVhr2HcE1Rvm3fe8g',
        beacon: 'TCPvgMqAmH46hG6NUsN6SFNHqNg92oKNBu',
        creationCode: '000',
      );
      expect(
        () => TronGasFree(GasFreeParameter(chainInfo: invalidChainInfo)),
        throwsArgumentError,
      );
    });
  });

  group('test TronGasFree address generation', () {
    late TronGasFree tronGasFree;

    setUp(() {
      tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
    });

    for (final data in _addressTestData) {
      test('test calcGasFreeAddress for ${data.user}', () {
        final salt = tronGasFree.calculateSalt(data.user);
        final bytecodeHash = tronGasFree.calculateBytecodeHash(
          data.user,
          nileBeacon,
          nileCreationCode,
        );

        expect(salt, equals(data.salt));
        expect(bytecodeHash, equals(data.bytecodeHash));

        final create2Address = ethToTronAddress(
          tronGasFree.calculateCreate2Address(
            salt,
            bytecodeHash,
            nileGasFreeController,
          ),
        );
        expect(create2Address, equals(data.gasFreeAddress));
      });

      test('test calculateGasFreeContractAddress for ${data.user}', () {
        final create2Address = ethToTronAddress(
          tronGasFree.calculateGasFreeContractAddress(
            data.user,
            nileGasFreeController,
            nileBeacon,
            nileCreationCode,
          ),
        );
        expect(create2Address, equals(data.gasFreeAddress));
      });

      test('test generateGasFreeAddress for ${data.user}', () {
        final gasFreeAddress = tronGasFree.generateGasFreeAddress(data.user);
        expect(gasFreeAddress, equals(data.gasFreeAddress));
      });
    }

    test('test calculateSalt - should throw error for invalid address', () {
      expect(() => tronGasFree.calculateSalt('invalid'), throwsArgumentError);
    });

    test('test addFunctionSelectorToAddress - should throw error for invalid address', () {
      expect(() => tronGasFree.addFunctionSelectorToAddress('invalid'), throwsArgumentError);
    });

    test('test calculateBytecodeHash - should throw error for invalid address', () {
      expect(
        () => tronGasFree.calculateBytecodeHash('invalid', '0x1234', '0x1234'),
        throwsArgumentError,
      );
    });

    test('test calculateGasFreeContractAddress - should throw error for invalid user address', () {
      expect(
        () => tronGasFree.calculateGasFreeContractAddress(
          'invalid',
          nileGasFreeController,
          nileBeacon,
          nileCreationCode,
        ),
        throwsArgumentError,
      );
    });

    test(
      'test generateGasFreeAddress should throw error when user address is invalid',
      () {
        expect(
          () => tronGasFree.generateGasFreeAddress('invalidAddress'),
          throwsArgumentError,
        );
      },
    );
  });

  group('test Ledger raw hash (EIP-712)', () {
    late TronGasFree tronGasFree;

    setUp(() {
      tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
    });

    for (final data in _messageTestData) {
      test('test getGasFreeLedgerRawHash', () {
        final result = tronGasFree.getGasFreeLedgerRawHash(message: data.message);

        expect(result.domainSeparatorHex, equals(_tronDomainSeparator));
        expect(result.hashStructMessageHex, equals(data.encodeMessage));
        expect(result.permitTransferMessageHash, equals(data.permitHash));
      });
    }
  });

  group('test assembleGasFreeTransactionJson', () {
    late TronGasFree tronGasFree;

    setUp(() {
      tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
    });

    test('should assemble valid transaction JSON', () {
      final params = AssembleGasFreeTransactionParams(
        token: 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf',
        serviceProvider: 'TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA',
        user: 'TLFXfejEMgivFDR2x8qBpukMXd56spmFhz',
        receiver: 'TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC',
        value: '10000',
        maxFee: '2000',
        deadline: '1726207632',
        version: '1',
        nonce: '2',
      );

      final result = tronGasFree.assembleGasFreeTransactionJson(params);

      // Check domain
      expect(result.domain.name, equals('GasFreeController'));
      expect(result.domain.version, equals('V1.0.0'));
      expect(result.domain.chainId, equals(TronChainId.nile.value));

      // Check types
      expect(result.types.containsKey('PermitTransfer'), isTrue);
      expect(result.types['PermitTransfer']!.length, equals(9));

      // Check message addresses are in TRON format
      expect(result.message.token, equals('TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf'));
      expect(result.message.serviceProvider, equals('TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA'));
      expect(result.message.user, equals('TLFXfejEMgivFDR2x8qBpukMXd56spmFhz'));
      expect(result.message.receiver, equals('TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC'));
      expect(result.message.value, equals('10000'));
      expect(result.message.maxFee, equals('2000'));
      expect(result.message.deadline, equals('1726207632'));
      expect(result.message.version, equals('1'));
      expect(result.message.nonce, equals('2'));
    });

    test('should throw error for invalid token address', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: 'invalid',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '10000',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid serviceProvider address', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: 'invalid',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '10000',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid user address', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: 'invalid',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '10000',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid receiver address', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: 'invalid',
            value: '10000',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid value', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: 'qqqq',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid maxFee', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '20000',
            maxFee: 'qqq',
            deadline: '1726207632',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid deadline', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '20000',
            maxFee: '2000',
            deadline: 'qqqq',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for negative deadline', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '20000',
            maxFee: '2000',
            deadline: '-1',
            version: '1',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid version', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '20000',
            maxFee: '2000',
            deadline: '1726207632',
            version: 'www',
            nonce: '2',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('should throw error for invalid nonce', () {
      expect(
        () => tronGasFree.assembleGasFreeTransactionJson(
          AssembleGasFreeTransactionParams(
            token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
            serviceProvider: '0x21E9464081d6e7964e383d52a45eC000a6171FCA',
            user: '0x9e747Ac885cD7bC5d0A2DfFCd23f5cCdEdCBD1c5',
            receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
            value: '20000',
            maxFee: '2000',
            deadline: '1726207632',
            version: '1',
            nonce: 'aa',
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('test checkIsValidGasFreeTypedDataParams', () {
    late TronGasFree tronGasFree;

    setUp(() {
      tronGasFree = TronGasFree(GasFreeParameter(chainId: TronChainId.nile.value));
    });

    test('should validate correct message', () {
      final validMessage = GasFreeTypedDataMessage(
        token: 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf',
        serviceProvider: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
        user: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
        receiver: 'TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC',
        value: '10000',
        maxFee: '2000',
        deadline: '1726207632',
        version: '1',
        nonce: '2',
      );

      expect(
        () => tronGasFree.checkIsValidGasFreeTypedDataParams(message: validMessage),
        returnsNormally,
      );
    });

    test('should throw error when token is not valid Tron address', () {
      final invalidMessage = GasFreeTypedDataMessage(
        token: '0xInvalidAddress',
        serviceProvider: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
        user: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
        receiver: 'TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC',
        value: '10000',
        maxFee: '2000',
        deadline: '1726207632',
        version: '1',
        nonce: '2',
      );

      expect(
        () => tronGasFree.checkIsValidGasFreeTypedDataParams(message: invalidMessage),
        throwsArgumentError,
      );
    });

    test('should throw error when user is not valid Tron address', () {
      final invalidMessage = GasFreeTypedDataMessage(
        token: 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf',
        serviceProvider: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',
        user: '0xInvalidAddress',
        receiver: 'TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC',
        value: '10000',
        maxFee: '2000',
        deadline: '1726207632',
        version: '1',
        nonce: '2',
      );

      expect(
        () => tronGasFree.checkIsValidGasFreeTypedDataParams(message: invalidMessage),
        throwsArgumentError,
      );
    });

    test('should throw error when message schema is invalid (missing fields)', () {
      // Will fail validation because of empty/default fields
      final invalidMessage = GasFreeTypedDataMessage(
        token: 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf',
        serviceProvider: '',
        user: '',
        receiver: '',
        value: '',
        maxFee: '',
        deadline: '',
        version: '',
        nonce: '',
      );

      expect(
        () => tronGasFree.checkIsValidGasFreeTypedDataParams(message: invalidMessage),
        throwsArgumentError,
      );
    });
  });
}
