<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.UPR.asl -->
# HL.SWI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SWI.UPR.asl`

HL.SWI.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-purpose role=purpose -->
## `HL.SWI.UPR` 的作用

`HL.SWI.UPR` 把来自 `SrcD` 的 `4` 字节小端单元存储到 `SrcR` 基址与不带比例的带符号立即数之和处，并把同一个和发布到 `RegDst`。

规范汇编是 `hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}`。

设计要点：前索引模式使内存地址与发布值成为同一个字。存储与基址更新绝不会指向两个不同的地址。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-mechanism role=mechanism -->
## 地址与结果如何形成

立即数存储的地址类型使 `SrcR` 成为基址。符号扩展后的 `simm17` 与 `SrcR` 快照按模 `2^PTO_XLEN` 相加，该和既用作地址，也用作发布的结果。

预检依次检查 `4` 字节对齐、转换、权限与有界内存。存储数据源从 `SrcD` 读取，只有整个地址都通过后才执行 `4` 字节小端存储并记录一个 relaxed 存储事件。

该和只在存储无故障完成之后到达 `RegDst`。

设计要点：发生故障时基址寄存器保持旧值，因为回写与存储共用同一个成功条件；因此发布的基址与被访问的地址始终是同一个字。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcD` 提供被存储的 `4` 字节。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 提供基址。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm17` 为带符号且不带比例，因此覆盖 `-65536`..`65535` 字节。
- `RegDst` 接收更新后的基址。编码 `1`..`23` 写 GPR，`30` 压入 `U` 队列，`31` 压入 `T` 队列，`0` 与 `24`..`29` 不发布任何结果；编码 `0` 是架构零寄存器，其写入被丢弃。
- 设计要点：队列目的端接收更新后的基址而不干扰 `SrcD` 数据通路，因此一条指令即可推进指针并将其压入队列。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-effects role=effects -->
## 效果、顺序与完成

所有源在内存操作之前取快照，因此与数据源或基址同名的目的端不会改变存储内容或位置。

成功时记录一个 relaxed 存储事件，只写该范围的 `4` 字节，发布更新后的基址，并使 `TPC` 前进 `6` 字节。

设计要点：只有当存储范围与持有该保留的 `64` 字节粒度重叠时才会作废保留，因此内存其他位置的存储会让它保持有效。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或所选 `T`/`U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。
- 不是 `4` 的倍数的和会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录事件、不写字节、不发布基址值，并让 `TPC` 停留在引发故障的指令上，使尝试可以重发。
- 设计要点：`4` 字节对齐规则同样作用于更新后的地址，因此未对齐的和会在转换之前被拒绝，且不发生任何变化。

<!-- PTO-READER-BLOCK: scalar-hl-swi-upr-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 以 GPR `6` = `0x1000` 为基址、`simm` = `4` 时，访问地址与发布的基址都是 `0x1004`。
- 当 `SrcD` = `0xDEADBEEF` 时，字节 `EF BE AD DE` 落在 `0x1004`..`0x1007`。
- 基址 `0x1002` 配 `simm` = `1` 会得到 `0x1003`，它不是 `4` 的倍数，因此会引发 `Fault_DataAlignment`，且基址保持 `0x1002`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | HL48 | 48 | 0x00006059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_upr_48_15c2fb96aab0 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_upr_48_15c2fb96aab0 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_swi_upr_48_15c2fb96aab0 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upr_48_15c2fb96aab0 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_upr_48_15c2fb96aab0 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI_UPR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI_UPR()
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
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
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

- hl.swi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
