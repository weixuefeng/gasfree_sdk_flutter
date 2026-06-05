# Changelog

All notable changes to the **gasfree_sdk_flutter** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-03-21

### Added

- **GasFree 地址生成** — 基于 CREATE2 + beacon proxy 计算免 Gas 合约地址。
  - `TronGasFree.generateGasFreeAddress()` — TRON 网络（base58 地址格式）
  - `EvmGasFree.generateGasFreeAddress()` — EVM 兼容链（0x 地址格式）
  - `GasFree.calculateSalt()` — 计算 CREATE2 salt
  - `GasFree.calculateBytecodeHash()` — 计算 bytecode hash
  - `GasFree.calculateCreate2Address()` — 计算 CREATE2 地址

- **EIP-712 Typed Data 组装** — 生成 PermitTransfer 标准消息。
  - `TronGasFree.assembleGasFreeTransactionJson()` — TRON 格式（地址使用 base58）
  - `EvmGasFree.assembleStandard712GasFreeTransactionJson()` — 标准 EVM 格式
  - 完整的类型定义：`Eip712Domain`、`Eip712TypeField`、`GasFreeTypedDataMessage`

- **Ledger 硬件签名哈希** — 计算离线签名所需哈希。
  - `GasFree.getGasFreeLedgerRawHash()` — 返回 `domainSeparatorHex`、`hashStructMessageHex`、`permitTransferMessageHash`

- **多链支持** — 通过联邦插件架构抽象。
  - `GasFreeParameter` — 统一参数配置，支持 `ChainInfo` 自定义
  - `TronChainId` 枚举 — 内置 TRON 主网、Nile 测试网、Shasta 测试网
  - 任意 EVM 链可通过自定义 `ChainInfo` 接入

- **核心依赖** — pointycastle（密码学）、bs58check（base58 编解码）、convert（hex 编码）

