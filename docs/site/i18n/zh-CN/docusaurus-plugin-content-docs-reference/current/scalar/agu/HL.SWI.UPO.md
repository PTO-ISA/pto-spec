<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.UPO.asl -->
# HL.SWI.UPO

**Normative ASL source:** `asl/scalar/agu/HL.SWI.UPO.asl`

HL.SWI.UPO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI-UPO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-purpose role=purpose -->
## `HL.SWI.UPO` 的作用

`HL.SWI.UPO` 是一条独立的 `48` 位标量 AGU 存储指令。它把来自 `SrcD` 的 `4` 字节小端单元写到 `SrcR` 基址处，并把前进后的基址发布到 `RegDst`。

规范汇编是 `hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}`。

设计要点：更新模式是后索引，因此存储使用的地址是原始基址，而这个和只是结果。后缀记录更新模式；`simm17` 位移不带比例，因此每个编码单位是一字节。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-mechanism role=mechanism -->
## 地址与结果如何形成

由于译出的地址类型是立即数存储，名为 `SrcR` 的字段提供的是基址而不是索引。符号扩展后的 `simm17` 与该基址按模 `2^PTO_XLEN` 相加，而存储访问的是基址本身。

预检依次检查 `4` 字节对齐、转换、权限与有界内存。存储数据源从 `SrcD` 读取，只有整个地址都通过后才执行 `4` 字节小端存储并记录一个 relaxed 存储事件。

若存储无故障完成，该和会发布到 `RegDst`，它可以是 GPR、队列压入或丢弃编码。

设计要点：回写与存储本身受同一个成功条件保护。发生故障的尝试会让基址寄存器保持旧值，并让 `TPC` 停留在该指令上，因此重发会重新计算完全相同的地址。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcD` 提供被写入的 `4` 字节。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 提供基址。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm17` 为带符号数，由于位移不带比例，它覆盖 `-65536`..`65535` 字节。编码零是零位移，而不是省略操作数。
- `RegDst` 接收更新后的基址。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：当 `SrcD` 与 `RegDst` 指向同一寄存器时，存储仍使用指令执行前的值：数据源在目的端写入之前读取。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-effects role=effects -->
## 效果、顺序与完成

所有源都在内存操作之前取快照，因此数据源与基址之间的别名不会改变被存储的字节或地址。

成功尝试记录一个 relaxed 存储事件，只写所存范围的 `4` 字节，发布该和，然后使 `TPC` 前进 `6` 字节。

设计要点：只有当存储范围与包含该保留的 `64` 字节粒度重叠时，存储才会作废保留，因此无关的存储会让保留保持有效。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或所选 `T`/`U` 源不可用，都会在任何指令效果之前于指令地址处引发 `Fault_IllegalInstruction`。
- 不是 `4` 的倍数的地址会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录存储事件，不写任何内存字节，不发布更新后的基址，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：对齐检查作用于基址，因为后索引的访问地址就是基址本身；不带比例的立即数只改变所发布的和，因此基址未对齐时会报告 `Fault_DataAlignment`，地址绝不会被取整到最近的单元。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upo-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 以 GPR `6` = `0x1000` 为基址、`simm` = `4` 时，和为 `0x1004`，但访问使用 `0x1000`，因为更新模式是后索引。
- 以 GPR `5` = `0xDEADBEEF` 作为 `SrcD` 时，写入 `0x1000`..`0x1003` 的字节是 `EF BE AD DE`。
- `RegDst` 只在存储完成之后收到 `0x1004`；若地址未对齐，内存与基址寄存器都会保持不变。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | HL48 | 48 | 0x00006059003e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_upo_48_243d3c38cd1a | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_upo_48_243d3c38cd1a | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_swi_upo_48_243d3c38cd1a | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upo_48_243d3c38cd1a | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upo_48_243d3c38cd1a | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPO.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI_UPO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI_UPO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI_UPO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI_UPO()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI_UPO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI_UPO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI_UPO()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}
