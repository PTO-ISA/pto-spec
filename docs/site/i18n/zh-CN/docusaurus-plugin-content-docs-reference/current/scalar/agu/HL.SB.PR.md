<!-- GENERATED FROM: asl/scalar/agu/HL.SB.PR.asl -->
# HL.SB.PR

**Normative ASL source:** `asl/scalar/agu/HL.SB.PR.asl`

HL.SB.PR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SB-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-purpose role=purpose -->
## `HL.SB.PR` 做什么

`HL.SB.PR` 是一条独立的 `48` 位标量 AGU 指令，通过寄存器位移存储一个来自 `SrcD` 的 `1` 字节小端序单元。

规范汇编形式是 `hl.sb.pr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}`。

设计要点：这是前变址形式，因此访问使用更新后的基址，而同一个更新后的基址在存储成功之后被发布。一条指令既推进指针，又通过新指针存储。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-mechanism role=mechanism -->
## 地址形成

位移是 `SrcR` 快照经 `SrcRType` 变换并左移固定的 `0` 位之后的值，再按 `2^PTO_XLEN` 取模加到 `SrcL` 快照上。

本寄存器寻址形式不携带 `shamt` 字段，因此缩放由形式固定，而不是每条指令各自选择。

地址在存储之前先经过预检。成功时执行一次 `1` 字节小端序存储，并记录一个 relaxed 存储事件。

设计要点：前变址的地址是基址加上变换后的位移，因此位移同时移动这次访问与发布的值：两者是同一个和。

设计要点：访问地址与发布的值是同一个和，因此 `->6` 且 `SrcL` = GPR6 会发布它刚刚用于存储的那个基址。写回仍然以存储成功为前提，因此发生故障时该寄存器保持旧值。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-inputs role=inputs-outputs -->
## 编码字段

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcRType` 是 `2` 位：`00` 保持整个 `SrcR` 值不变，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。
- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制其他影响。

设计要点：`SrcD` 可以与 `RegDst` 指定同一个寄存器。存储数据在任何目的位置影响之前被读取，因此内存操作存储的是指令执行前的值，而该寄存器之后保存的是更新后的基址。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-effects role=effects -->
## 影响

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当存储无故障完成时，更新后的基址会发布到 `RegDst`。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：只有 `SrcD` 的低 `8` 位被写入，因此更宽的值会被静默截断而不是引发故障。寄存器的其余部分不受影响。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-constraints role=constraints -->
## 合法性与故障

- 固定位不匹配、保留的 `SrcRType` 取值，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 每个地址都是整数个 `1` 字节单元，因此预检无法为本形式引发 `Fault_DataAlignment`。权限或有界内存失败会在原始地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。
- 设计要点：`0` 是被赋予含义的 `RegDst` 编码，因此 `->0` 会存储并丢弃更新后的基址；`0` 在这里不是保留编码。除了写入被丢弃之外，丢弃与写入零号 GPR 没有任何区别。

<!-- PTO-READER-BLOCK: scalar-hl-sb-pr-example role=example -->
## 完整示例

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sb.pr 5, [6, 7], ->8`，GPR6 = `0x2000`，GPR7 = `0x11`，GPR5 = `0xABCD`。
- 前变址的地址是 `0x2011`，因此字节 `0xCD` 被存储到该处。
- GPR8 收到 `0x2011`，并且 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sb.pr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sb_pr_48_40eae4513905 | HL48 | 48 | 0x00000049002e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sb_pr_48_40eae4513905 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sb_pr_48_40eae4513905 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sb_pr_48_40eae4513905 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sb_pr_48_40eae4513905 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sb_pr_48_40eae4513905 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sb_pr_48_40eae4513905 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sb_pr_48_40eae4513905 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sb_pr_48_40eae4513905 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sb_pr_48_40eae4513905 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sb_pr_48_40eae4513905 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sb_pr_48_40eae4513905.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SB.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SB_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SB_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SB.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SB_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SB_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SB_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SB_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SB_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SB_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SB_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SB_PR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. The register offset uses a fixed scale factor of 1; no shamt field is encoded.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- All four SrcRType values are assigned; apply the selected modifier with the fixed scale factor of 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sb.pr SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
