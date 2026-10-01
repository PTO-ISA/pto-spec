<!-- GENERATED FROM: asl/scalar/agu/HL.SBP.asl -->
# HL.SBP

**Normative ASL source:** `asl/scalar/agu/HL.SBP.asl`

HL.SBP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SBP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sbp-purpose role=purpose -->
## `HL.SBP` 的作用

`HL.SBP` 是一条独立的 `48` 位标量 AGU 指令，从 `SrcD` 与 `SrcD1` 存出两个相邻的 `1` 字节小端单元。

规范汇编形式为 `hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]`。

设计要点：两个被存储的值都来自寄存器，且这一对单元覆盖两个相邻字节。因此对两个源各做一次 `1` 字节写入就是一条指令，并且两个源都不会被修改。

<!-- PTO-READER-BLOCK: scalar-hl-sbp-mechanism role=mechanism -->
## `HL.SBP` 如何构成地址并完成传输

偏移是 `SrcR` 快照经 `SrcRType` 变换后，再左移固定的 `0` 位，然后加到 `SrcL` 快照上并对 `2^PTO_XLEN` 取模。

该和就是第一个地址，第二个地址是该和加 `1`。更新模式为无，因此不发布任何基址回写。

两个地址都会被预检，两个存储数据源也都会在第一次存储之前被读取。发生故障时，两个单元都不会被写入。

设计要点：两个单元在任何一个字节被写入之前都已预检，因此第二个单元上的故障不可能让这一对的第一个字节已经被存储。

设计要点：寄存器偏移的缩放量为 `0`，所以 `SrcR` 按字节计数，这对单元的第二个字节正好比第一个高一个字节。同一个偏移寄存器可以当作字节游标重复使用。

<!-- PTO-READER-BLOCK: scalar-hl-sbp-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcD1` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcRType` 是 `2` 位：`00` 保持整个 `SrcR` 值不变，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。
- 本形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不发布更新后的基址。

设计要点：`SrcD` 与 `SrcD1` 可以指定同一个寄存器，此时两个字节都会由同一次指令执行前的读取得到相同的值。第二次读取不会观察到第一次存储，因为两个源都在第一次存储之前被读取。

<!-- PTO-READER-BLOCK: scalar-hl-sbp-effects role=effects -->
## 效果、快照与完成顺序

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

成功执行会按地址递增顺序记录两个 relaxed 存储事件。

在内存方面，执行成功只改变所存范围之内的字节。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

设计要点：每个源只有低 `8` 位会被写入，因此更宽的源会被静默截断。每个寄存器的其余部分不受影响。

<!-- PTO-READER-BLOCK: scalar-hl-sbp-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 每个地址都是 `1` 字节单元的整数倍，因此本形式的预检不会引发 `Fault_DataAlignment`。权限或受限内存失败会在失败单元自身的地址引发 `Fault_DataPage`：当只有第二个单元未通过边界或权限检查时，报告的是第二个地址。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。

设计要点：`SrcRType` 原始值 `11` 为保留值，会在读取源之前被拒绝，因此保留的选择子不可能暴露出半成形的偏移。

<!-- PTO-READER-BLOCK: scalar-hl-sbp-example role=example -->
## 非规范阅读示例

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sbp 20, 21, [2, 7]`，其中 GPR2 = `0x8000`、GPR7 = `0x10`、GPR20 = `0xAA`、GPR21 = `0xBB`。
- 偏移是 `0x10`，因此两个地址为 `0x8010` 与 `0x8011`。
- 字节 `0xAA` 存储在 `0x8010`，字节 `0xBB` 存储在 `0x8011`。
- 没有寄存器发生变化，`TPC` 变为指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sbp_48_12e03c011f0a | HL48 | 48 | 0x00000049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sbp_48_12e03c011f0a | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sbp_48_12e03c011f0a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sbp_48_12e03c011f0a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sbp_48_12e03c011f0a | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sbp_48_12e03c011f0a.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBP() => ScalarOperation
begin
    return ScalarOperation_HL_SBP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SBP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SBP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SBP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SBP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBP()
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
- All four SrcRType values are assigned; apply the selected modifier with the fixed scale factor of 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
