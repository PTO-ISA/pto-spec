<!-- GENERATED FROM: asl/scalar/agu/HL.SHI.PO.asl -->
# HL.SHI.PO

**Normative ASL source:** `asl/scalar/agu/HL.SHI.PO.asl`

HL.SHI.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SHI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shi-po-purpose role=purpose -->
## `HL.SHI.PO` 存储什么

`HL.SHI.PO` 是一条独立的 `48` 位标量 AGU 指令，在 `SrcR` 基址上存储来自 `SrcD` 的一个小端 `2` 字节单元，并通过 `RegDst` 发布推进后的基址。

规范汇编是 `hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}`。

设计要点：按 `2` 缩放的位移可以在 `17` 位有符号字段内覆盖所有偶数字节位移，因此 `2` 字节的遍历只用位移即可表达，不需要索引寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-mechanism role=mechanism -->
## 地址如何形成

位移是符号扩展后的 `simm17` 值乘以 `2`，再按 `2^PTO_XLEN` 取模加到 `SrcR` 快照上，得到计算出的地址。

标度为 `1`，因此位移以 `2` 字节单元计数：把它加 `1` 会让访问位置移动 `2` 字节。

更新模式为后索引：访问使用原始的 `SrcR` 值，而 `SrcR` 与位移之和只在存储成功之后才发布给 `RegDst`。

预检在存储之前进行，`SrcD` 在该预检之前读取；成功时执行一次 `2` 字节小端存储并记录一个 relaxed 存储事件。

设计要点：编码域 `-65536..65535` 乘以 `2` 后得到从 `-131072` 到 `131070` 的所有偶数字节位移；奇数位移根本无法编码。

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-inputs role=inputs-outputs -->
## 操作数

- `SrcD` 与 `SrcR` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `simm17` 是 `17` 位有符号字段，分配从 `-65536` 到 `65535` 的全部值；编码字节位移是该值乘以 `2`，编码零表示零位移而不是省略。

- `RegDst` 是 `5` 位目的选择子：编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制存储。

设计要点：`RegDst` 可以指定 `SrcR` 或 `SrcD`；基址与存储值都在存储之前读取，因此回写不会影响地址或数据。

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-effects role=effects -->
## 影响与顺序

`SrcR` 与 `SrcD` 都在存储之前读取，因此即使 `RegDst` 指定其中之一，也不会改变基址或存储数据。

执行成功时记录一个 relaxed 存储事件，只改变该单元的 `2` 字节。

当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

更新后的基址在存储之后发布，随后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：推进后的基址是原始基址加上缩放后的位移，因此用递增位移编码的循环可以按走过的总距离推进指针。

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-constraints role=constraints -->
## 对齐、故障与重启

- 有效地址必须是 `2` 的倍数。未对齐的地址会在地址转换或权限检查之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- 发生故障时不记录存储事件也不发布基址：内存、`SrcD`、`RegDst` 与 `TPC` 保持原值，恢复时重新计算快照、地址、预检与存储。

设计要点：对齐规则约束的是后索引的访问地址，也就是原始基址；发布的和不受约束，可以是奇数。

<!-- PTO-READER-BLOCK: scalar-hl-shi-po-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.shi.po 20, [2, 3], ->4`，其中 GPR2 = `0x1000` 与 GPR20 = `0xbeef`。

- 位移 `3` 乘以 `2` 得到 `6`；访问使用原始基址 `0x1000`，并把和 `0x1006` 发布给 `RegDst` `4`。

- 该存储按地址递增顺序把 `0xef`、`0xbe` 写到 `0x1000` 到 `0x1001`。

- `SrcD` 与 `SrcR` 保持指令执行前的值，`RegDst` `4` 收到 `0x1006` 之后 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shi_po_48_636fea832c7b | HL48 | 48 | 0x00001059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shi_po_48_636fea832c7b | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shi_po_48_636fea832c7b | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shi_po_48_636fea832c7b | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_shi_po_48_636fea832c7b | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shi_po_48_636fea832c7b | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shi_po_48_636fea832c7b | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SHI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SHI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SHI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHI_PO()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHI_PO()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SHI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHI_PO()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcR base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.shi.po SrcD, [SrcR, simm], ->{t, u, Rd}
