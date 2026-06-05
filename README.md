# gasfree_sdk

A Dart SDK for GasFree transactions, ported from [gasfree-sdk-js](https://github.com/gasfreeio/gasfree-sdk-js).

Supports EVM-compatible chains and the TRON network. Provides GasFree address generation (CREATE2-based), EIP-712 typed data assembly for PermitTransfer messages, and Ledger hardware wallet signing hash computation.

## Features

- **GasFree 地址生成** — 基于 CREATE2 + beacon proxy 计算免 Gas 合约地址
- **EIP-712 Typed Data 组装** — 生成 PermitTransfer 标准消息，支持签名 / 发送
- **Ledger 硬件签名哈希** — 计算 domainSeparator + hashStructMessage 用于离线签名
- **多链支持** — TRON（主网 / Nile / Shasta）+ 任意 EVM 兼容链
- **联邦插件架构** — 抽象 `GasFree` 基类，`TronGasFree` 和 `EvmGasFree` 两个实现

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  gasfree_sdk_flutter:
    path: ./gasfree_sdk_flutter
```

或者发布到 pub.dev 后：

```yaml
dependencies:
  gasfree_sdk_flutter: ^1.0.0
```

## 快速开始

### 初始化

使用 TRON Nile 测试网默认配置：

```dart
import 'package:gasfree_sdk_flutter/gasfree_sdk.dart';

final tronGasFree = TronGasFree(
  GasFreeParameter(chainId: TronChainId.nile.value),
);
```

使用主网：

```dart
final tronGasFree = TronGasFree(
  GasFreeParameter(chainId: TronChainId.mainnet.value),
);
```

使用自定义链配置：

```dart
final tronGasFree = TronGasFree(
  GasFreeParameter(
    chainInfo: ChainInfo(
      chainId: 12345,
      gasFreeController: '0x...',
      beacon: '0x...',
      creationCode: '0x...',
    ),
  ),
);
```

使用 EVM 兼容链（非 TRON）：

```dart
final evmGasFree = EvmGasFree(
  GasFreeParameter(chainId: 1), // Ethereum mainnet
);
```

### 生成 GasFree 地址

```dart
try {
  const userAddress = 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC';
  final tronGasFree = TronGasFree(
    GasFreeParameter(chainId: TronChainId.nile.value),
  );
  final gasFreeAddress = tronGasFree.generateGasFreeAddress(userAddress);
  print('GasFree Address: $gasFreeAddress');
} catch (e) {
  print('Error: $e');
}
```

不同链和不同的 GasFreeController 会产生不同的 GasFree 地址。

### 组装 EIP-712 交易数据

组装标准 TIP-712（EIP-712）免 Gas 交易 JSON：

```dart
try {
  final tronGasFree = TronGasFree(
    GasFreeParameter(chainId: TronChainId.nile.value),
  );

  final txJson = tronGasFree.assembleGasFreeTransactionJson(
    AssembleGasFreeTransactionParams(
      token: 'TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf',      // TRC20 合约地址
      serviceProvider: 'TDbJyQ6g1Lx9BAfEEeN5S5TMjjDRAVFCaA', // 服务提供方
      user: 'TMVQGm1qAQYVdetCeGRRkTWYYrLXuHK2HC',        // 用户地址
      receiver: 'TJM1BE5wq1VdHh3gwjUeyaVkvZp9DVYCfC',     // 接收地址
      value: '10000',                                       // 转账金额（十进制字符串）
      maxFee: '2000',                                       // 最大手续费
      deadline: '1726207632',                               // 截止时间戳
      version: '1',                                          // 签名算法版本
      nonce: '2',                                           // 交易 nonce
    ),
  );

  print('Domain: ${txJson.domain}');
  print('Message: ${txJson.message}');
  print('Types: ${txJson.types}');
} catch (e) {
  print('Error: $e');
}
```

### 计算 Ledger 硬件签名哈希

用于 Ledger 等硬件钱包离线签名的原始哈希：

```dart
import 'package:gasfree_sdk_flutter/gasfree_sdk.dart';

try {
  final tronGasFree = TronGasFree(
    GasFreeParameter(chainId: TronChainId.nile.value),
  );

  final ledgerHash = tronGasFree.getGasFreeLedgerRawHash(
    message: GasFreeTypedDataMessage(
      token: '0xECa9bC828A3005B9a3b909f2cc5c2a54794DE05F',
      serviceProvider: '0x70C77E8aC165d2980E9741cB4Af2E40cF3C280de',
      user: '0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf',
      receiver: '0x5bE049630A2c8B18F1B6BF53bE95120A3f982fcc',
      value: '10000',
      maxFee: '2000',
      deadline: '1726207632',
      version: '1',
      nonce: '2',
    ),
  );

  print('Domain Separator: ${ledgerHash.domainSeparatorHex}');
  print('Message Hash: ${ledgerHash.hashStructMessageHex}');
  print('Permit Hash: ${ledgerHash.permitTransferMessageHash}');
} catch (e) {
  print('Error: $e');
}
```

### EVM 链用法

```dart
import 'package:gasfree_sdk_flutter/gasfree_sdk.dart';

final evmGasFree = EvmGasFree(
  GasFreeParameter(
    chainInfo: ChainInfo(
      chainId: 1,
      gasFreeController: '0x...',
      beacon: '0x...',
      creationCode: '0x...',
    ),
  ),
);

// 生成 GasFree 地址（返回 0x 格式）
final evmAddress = evmGasFree.generateGasFreeAddress('0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf');

// 组装标准 EIP-712 数据
final txData = evmGasFree.assembleStandard712GasFreeTransactionJson(
  AssembleGasFreeTransactionParams(
    token: '0x...',
    serviceProvider: '0x...',
    user: '0x...',
    receiver: '0x...',
    value: '10000',
    maxFee: '2000',
    deadline: '1726207632',
    version: '1',
    nonce: '2',
  ),
);
```

## API 概览

### TronGasFree

| 方法 | 说明 |
|------|------|
| `generateGasFreeAddress(userAddress)` | 根据用户 TRON 地址生成 GasFree 地址 |
| `assembleGasFreeTransactionJson(params)` | 组装 TRON 格式的 EIP-712 交易 JSON |
| `getGasFreeLedgerRawHash(message)` | 计算 Ledger 离线签名哈希 |
| `calculateSalt(address)` | 计算 CREATE2 salt |
| `calculateBytecodeHash(address, beacon, creationCode)` | 计算 bytecode hash |
| `calculateCreate2Address(salt, bytecodeHash, controller)` | 计算 CREATE2 地址 |

### EvmGasFree

| 方法 | 说明 |
|------|------|
| `generateGasFreeAddress(userAddress)` | 根据用户 EVM 地址生成 GasFree 地址 |
| `assembleStandard712GasFreeTransactionJson(params)` | 组装标准 EVM EIP-712 交易 JSON |
| `getGasFreeLedgerRawHash(message)` | 计算 Ledger 离线签名哈希 |

## 开发

```bash
# 获取依赖
dart pub get

# 分析代码
dart analyze

# 运行测试
dart test
```

## License

Apache-2.0
# gasfree_sdk_flutter
