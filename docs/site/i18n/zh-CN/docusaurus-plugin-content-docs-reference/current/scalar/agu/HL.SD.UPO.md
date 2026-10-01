<!-- GENERATED FROM: asl/scalar/agu/HL.SD.UPO.asl -->
# HL.SD.UPO

**Normative ASL source:** `asl/scalar/agu/HL.SD.UPO.asl`

HL.SD.UPO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SD-UPO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-purpose role=purpose -->
## `HL.SD.UPO` 做什么

`HL.SD.UPO` 是一条独立的 `48` 位标量 AGU 指令，通过寄存器位移存储一个来自 `SrcD` 的 `8` 字节小端序单元。

规范汇编形式是 `hl.sd.upo SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}`。

设计要点：这是未缩放 `8` 字节存储的后变址形式，因此访问使用原始基址，更新后的基址只在存储成功之后才发布。`.u` 后缀去掉了隐含的 `8` 字节缩放，因此位移寄存器以字节计数。

<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-mechanism role=mechanism -->
## 地址形成

位移是 `SrcR` 快照经 `SrcRType` 变换并左移固定的 `0` 位之后的值，再按 `2^PTO_XLEN` 取模加到 `SrcL` 快照上。

本寄存器寻址形式不携带 `shamt` 字段，因此缩放由形式固定，而不是每条指令各自选择。

地址在存储之前先经过预检。成功时执行一次 `8` 字节小端序存储，并记录一个 relaxed 存储事件。

设计要点：后变址的地址就是基址本身，因此位移不移动这次访问。位移只为写回而加到基址上，所以发布的值是 `SrcL` 加上变换后的位移。由于位移量为 `0`，该位移是字节距离，可以把指针移动任意字节数。

设计要点：写回以存储无故障完成为前提。重试发生故障的 `HL.SD.UPO` 的程序会再次得到同一个基址，因此重试无法越过那个失败的元素继续前进。

<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-inputs role=inputs-outputs -->
## 编码字段

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcL` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcRType` 是 `2` 位：`00` 保持整个 `SrcR` 值不变，`01` 与 `10` 分别用其低 `32` 位的有符号与无符号读法替换它，`11` 为保留值。
- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制其他影响。

设计要点：字节粒度的位移让同一种形式把指针推进任意字节数，例如把数据存进紧凑记录。从该指针出发的下一次存储仍然必须自行满足 `8` 字节对齐规则。

<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-effects role=effects -->
## 影响

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当存储无故障完成时，更新后的基址会发布到 `RegDst`。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcD` 的全部 `8` 字节都是传输内容，因此最低字节落在该单元的最低地址。本形式没有截断。

<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-constraints role=constraints -->
## 合法性与故障

- 固定位不匹配、保留的 `SrcRType` 取值，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 未对齐的 `8` 字节地址会在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。
- 设计要点：字节粒度的位移可能产生低 `3` 位不为 `0` 的基址，之后从该基址出发的访问就会因对齐而发生故障。发布出去的基址仍然精确等于本指令算出的和；没有任何检查确认它适合之后的 `8` 字节访问。

<!-- PTO-READER-BLOCK: scalar-hl-sd-upo-example role=example -->
## 完整示例

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sd.upo 5, [6, 7], ->8`，GPR6 = `0x2000`，GPR7 = `-8`，GPR5 = `0x0807060504030201`。
- 后变址的地址是 `0x2000`，那 `8` 个字节被存储到该处。
- GPR8 收到 `0x1FF8`，并且 `TPC` 前进 `6` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sd.upo SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sd_upo_48_ba930fbec5c7 | HL48 | 48 | 0x00007049003e / 0x00007fff07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sd_upo_48_ba930fbec5c7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sd_upo_48_ba930fbec5c7 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sd_upo_48_ba930fbec5c7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sd_upo_48_ba930fbec5c7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sd_upo_48_ba930fbec5c7 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sd_upo_48_ba930fbec5c7 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sd_upo_48_ba930fbec5c7 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sd_upo_48_ba930fbec5c7 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sd_upo_48_ba930fbec5c7 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sd_upo_48_ba930fbec5c7 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_sd_upo_48_ba930fbec5c7.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SD.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_SD_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SD_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SD.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_SD_UPO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SD_UPO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SD_UPO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SD_UPO()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SD_UPO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SD_UPO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SD_UPO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SD_UPO()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
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

- hl.sd.upo SrcD, [SrcL, SrcR<{.sw,.uw}>], ->{t, u, Rd}
