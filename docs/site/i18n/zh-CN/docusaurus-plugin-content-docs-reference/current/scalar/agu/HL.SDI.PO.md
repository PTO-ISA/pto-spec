<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.PO.asl -->
# HL.SDI.PO

**Normative ASL source:** `asl/scalar/agu/HL.SDI.PO.asl`

HL.SDI.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-purpose role=purpose -->
## `HL.SDI.PO` 做什么

`HL.SDI.PO` 是一条独立的 `48` 位标量 AGU 指令，它把来自 `SrcD` 的 `8` 字节小端单元存储在相对 `SrcR` 基址的带符号 `simm17` 位移处。

规范汇编是 `hl.sdi.po SrcD, [SrcR, simm], ->{t, u, Rd}`。

这是后索引形式：访问使用原始基址，更新后的基址只在存储成功之后才发布。位移按 `8` 缩放，因此编码字段按 `8` 字节单元计数。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-mechanism role=mechanism -->
## 地址与传输如何形成

位移是带符号扩展的 `simm17` 值左移 `3` 位，并与 `SrcR` 快照按模 `2^PTO_XLEN` 相加。基址在任何内存影响之前读取，因此稍后对同一寄存器的写回无法改变这次存储使用的地址。

地址在存储之前经过预检。成功时执行一次 `8` 字节小端存储，并记录一个 relaxed 存储事件。

后索引地址就是基址本身，因此位移不会移动这次访问；它只为了写回而与基址相加，并以整 `8` 字节单元推进发布的指针。

设计要点：写回以存储无故障完成为前提，因此对发生故障的 `HL.SDI.PO` 重试会看到同一个基址并算出同一个地址。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-inputs role=inputs-outputs -->
## 编码字段与作用

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是带符号 `17` 位位移，单位为 `8` 字节，在编码中由 3 部分组成：位 `41`..`47`、位 `23`..`27` 与位 `6`..`10`，覆盖 `-65536`..`65535` 个单元。
- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制其他影响。
- 设计要点：带比例的立即数索引让编码字段保持窄小，而可达范围仍然很大，因为比例是乘在计数上，而不是把字段加宽。`17` 位字段覆盖 `-65536`..`65535` 个单元，即 `-524288`..`524280` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当存储无故障完成时，更新后的基址会发布到 `RegDst`。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcD` 的全部 `8` 字节都是传输内容，因此最低字节落在该单元的最低地址。不存在截断。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 未对齐的 `8` 字节地址在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或受限内存失败会在原地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。
- 设计要点：无论索引是多少，发布的基址与原基址对齐性完全一致，因为带比例的位移始终是 `8` 的倍数。未对齐的基址在步进的每一步都保持未对齐。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-po-example role=example -->
## 端到端读一条编码

下面只说明如何使用本页，不增加指令行为。

- 假设 `hl.sdi.po 5, [6, 2], ->8` 执行时 GPR6 = `0x2000`，GPR5 = `0x0807060504030201`。
- 后索引地址是 `0x2000`，因此 `8` 字节被存储在那里。
- 位移是 `2` 个单元，即 `0x10`，因此存储成功之后 GPR8 收到 `0x2010`。
- 其他内存字节与其他寄存器都不改变，且 `TPC` 变为指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdi.po SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_po_48_4b6af4b433bb | HL48 | 48 | 0x00003059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_po_48_4b6af4b433bb | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sdi_po_48_4b6af4b433bb | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_po_48_4b6af4b433bb | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_po_48_4b6af4b433bb | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_po_48_4b6af4b433bb | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sdi_po_48_4b6af4b433bb | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_po_48_4b6af4b433bb | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_po_48_4b6af4b433bb | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_PO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_PO()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_PO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcR base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sdi.po SrcD, [SrcR, simm], ->{t, u, Rd}
