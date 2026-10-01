<!-- GENERATED FROM: asl/scalar/agu/HL.SW.PO.asl -->
# HL.SW.PO

**Normative ASL source:** `asl/scalar/agu/HL.SW.PO.asl`

HL.SW.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SW-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sw-po-purpose role=purpose -->
## `HL.SW.PO` 存储什么

`HL.SW.PO` 是一条独立的 `48` 位标量 AGU 指令，存储来自 `SrcD` 的一个小端 `4` 字节单元，并通过 `RegDst` 发布推进后的基址。

规范汇编是 `hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw}><<2], ->{t, u, Rd}`。

设计要点：访问保持原始基址，推进后的基址单独发布，因此拷贝循环可以一边通过指针存储一边推进它，而不丢失刚刚用过的地址。

<!-- PTO-READER-BLOCK: scalar-hl-sw-po-mechanism role=mechanism -->
## 地址如何形成

位移是经 `SrcRType` 选择后的 `SrcR` 快照，左移 `2` 位，再按 `2^PTO_XLEN` 取模加到 `SrcL` 快照上，得到计算出的地址。

标度为 `2`，因此编码的寄存器位移以 `4` 字节单元计数：索引为 `1` 时发布的基址前进 `4` 字节。

更新模式为后索引：访问使用原始的 `SrcL` 值，而 `SrcL` 与位移之和只在存储成功之后才发布给 `RegDst`。

预检在存储之前进行，`SrcD` 在该预检之前读取；成功时执行一次 `4` 字节小端存储并记录一个 relaxed 存储事件。

设计要点：后索引的访问地址是原始基址 `0x2000`，因此 `4` 字节单元写在基址处，索引只决定指针接下来移动到哪里。

<!-- PTO-READER-BLOCK: scalar-hl-sw-po-inputs role=inputs-outputs -->
## 操作数

- `SrcD`、`SrcL` 与 `SrcR` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `SrcRType` 是 `2` 位，在移位之前作用于 `SrcR`：`00` 保持整个寄存器值，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。

- `RegDst` 是 `5` 位目的选择子：编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制存储。

设计要点：`RegDst` 是完整的 Reg5 目的选择子，因此推进后的基址可以压入 `T` 或 `U` 队列而不是 GPR，也可以通过编码 `0` 丢弃。

<!-- PTO-READER-BLOCK: scalar-hl-sw-po-effects role=effects -->
## 影响与顺序

`SrcL`、`SrcR` 与 `SrcD` 都在存储之前读取，因此即使 `RegDst` 指定其中之一，也不会改变基址、位移或存储数据。

执行成功时记录一个 relaxed 存储事件，只改变该单元的 `4` 字节。

当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

更新后的基址在存储之后发布，随后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：存储在回写之前记录，因此内存事件与指针更新是有序的，故障只会抑制指针更新。

<!-- PTO-READER-BLOCK: scalar-hl-sw-po-constraints role=constraints -->
## 对齐、故障与重启

- 有效地址必须是 `4` 的倍数。未对齐的地址会在地址转换或权限检查之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- `SrcRType` 的原始值 `11` 为保留值：它会在读取任何源之前于 `PC` 处引发 `Fault_IllegalInstruction`，因此地址修饰符解码只定义 `00`、`01` 与 `10`。

- 发生故障时不记录存储事件也不发布基址：内存、`SrcD`、`RegDst` 与 `TPC` 保持原值，恢复时重新计算快照、地址、预检与存储。

设计要点：未对齐的基址会在地址转换之前引发 `Fault_DataAlignment`，并且不会为该地址产生权限或有界内存的结果。

<!-- PTO-READER-BLOCK: scalar-hl-sw-po-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.sw.po 20, [2, 7<<2], ->4`，其中 `SrcRType` 为 `01`，GPR2 = `0x2000`，GPR7 = `0x4` 与 GPR20 = `0xdeadbeef`。

- 索引 `0x4` 左移 `2` 位得到位移 `16`；访问使用原始基址 `0x2000`，并把和 `0x2010` 发布给 `RegDst` `4`。

- 该存储按地址递增顺序把 `0xef`、`0xbe`、`0xad`、`0xde` 写到 `0x2000` 到 `0x2003`。

- `SrcD` 与 `SrcL` 保持指令执行前的值，`RegDst` `4` 收到 `0x2010` 之后 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw}><<2], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | HL48 | 48 | 0x00002049003e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sw_po_48_84cf0cd97fde | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sw_po_48_84cf0cd97fde | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sw_po_48_84cf0cd97fde.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SW_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SW_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SW_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SW_PO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SW_PO()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SW_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SW_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SW_PO()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw}><<2], ->{t, u, Rd}
