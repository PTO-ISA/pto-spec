<!-- GENERATED FROM: asl/scalar/agu/HL.SWIP.U.asl -->
# HL.SWIP.U

**Normative ASL source:** `asl/scalar/agu/HL.SWIP.U.asl`

HL.SWIP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SWIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swip-u-purpose role=purpose -->
## `HL.SWIP.U` 的作用

`HL.SWIP.U` 用一条指令把来自 `SrcD` 与 `SrcD1` 的两个相邻 `4` 字节小端单元存储到距 `SrcR` 基址的、不带比例的带符号立即数位移处。

规范汇编是 `hl.swip.u SrcD, SrcD1, [SrcR, simm]`。

设计要点：`.u` 形式去掉 `4` 字节比例，因此 `simm17` 以字节计数并覆盖 `-65536`..`65535`。这一对仍然是位于 `address` 与 `address + 4` 的两个 `4` 字节单元。

<!-- PTO-READER-BLOCK: scalar-hl-swip-u-mechanism role=mechanism -->
## 两个地址与传输如何形成

由于地址类型是立即数存储，`SrcR` 是基址。符号扩展后的 `simm17` 与之按模 `2^PTO_XLEN` 相加得到第一个地址；第二个地址是第一个地址加 `4`。

两个地址按顺序、在任何存储发起之前都经过预检：对齐、转换、权限。只有两个预检都通过后，才读取 `SrcD` 与 `SrcD1`，并按地址顺序提交两次 relaxed `4` 字节存储。

本形式没有目的端选择子，因此没有寄存器记录这两个地址中的任何一个。

设计要点：由于第二个地址在第一次存储提交之前就已校验，第二个单元出错时第一个单元不会被写入；一对存储绝不会只完成一半。

<!-- PTO-READER-BLOCK: scalar-hl-swip-u-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcD` 提供第一个地址处的单元，`SrcD1` 提供第二个地址处的单元。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 提供基址。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm17` 为带符号数，由于不带比例，它覆盖 `-65536`..`65535` 字节。
- 设计要点：存储不消费 `SrcD` 或 `SrcD1`，因此用作某一对后半部分的值可以成为下一对的前半部分。

<!-- PTO-READER-BLOCK: scalar-hl-swip-u-effects role=effects -->
## 效果、顺序与完成

所有源在第一次存储之前取快照，因此被存储的字节不依赖本指令写入的任何内容。

成功时写入两个相邻的 `4` 字节范围，按地址顺序记录两个 relaxed 存储事件，并使 `TPC` 前进 `6` 字节。

设计要点：只有这两个范围发生变化；只有当其中之一与某个保留的 `64` 字节粒度重叠时，该保留才会被作废。

<!-- PTO-READER-BLOCK: scalar-hl-swip-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或所选 `T`/`U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。
- 第一或第二个地址不是 `4` 的倍数时，会在任何存储之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在失败的那个地址处引发 `Fault_DataPage`。
- 故障不记录存储事件，不写两个单元中的任何字节，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：不带比例的立即数可以是奇数，因此即使基址对齐，本形式也可能产生未对齐的地址；决定余数的是立即数，而不是基址。

<!-- PTO-READER-BLOCK: scalar-hl-swip-u-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 当 GPR `6` = `0x2000`、`simm` = `2` 时，两个地址是 `0x2002` 与 `0x2006`；第一个不是 `4` 的倍数，因此引发 `Fault_DataAlignment`。
- 当 `simm` = `4` 时地址变为 `0x2004` 与 `0x2008`，两个单元都会被写入。
- 当 `SrcD` = `0x0000000011223344`、`SrcD1` = `0x0000000055667788` 时，字节 `44 33 22 11` 落在 `0x2004`，`88 77 66 55` 落在 `0x2008`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swip.u SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swip_u_48_e2dc917c8505 | HL48 | 48 | 0x00006059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swip_u_48_e2dc917c8505 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swip_u_48_e2dc917c8505 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swip_u_48_e2dc917c8505 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swip_u_48_e2dc917c8505 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swip_u_48_e2dc917c8505 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swip_u_48_e2dc917c8505 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SWIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SWIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWIP_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWIP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWIP_U()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.swip.u SrcD, SrcD1, [SrcR, simm]
