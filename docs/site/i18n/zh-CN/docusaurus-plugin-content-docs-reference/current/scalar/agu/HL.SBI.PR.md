<!-- GENERATED FROM: asl/scalar/agu/HL.SBI.PR.asl -->
# HL.SBI.PR

**Normative ASL source:** `asl/scalar/agu/HL.SBI.PR.asl`

HL.SBI.PR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SBI-PR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-purpose role=purpose -->
## `HL.SBI.PR` 做什么

`HL.SBI.PR` 是一条独立的 `48` 位标量 AGU 指令，它把来自 `SrcD` 的 `1` 字节小端单元存储在相对 `SrcR` 基址的带符号 `simm17` 位移处。

规范汇编是 `hl.sbi.pr SrcD, [SrcR, simm], ->{t, u, Rd}`。

这是前索引形式：访问使用更新后的基址，同一个更新后的基址在存储成功之后发布。位移不带比例，因此一个恒定的字节步长同时移动访问与打印出的指针。

<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-mechanism role=mechanism -->
## 地址与传输如何形成

位移是带符号扩展的 `simm17` 值，位移量为 `0`，并与 `SrcR` 快照按模 `2^PTO_XLEN` 相加。基址在任何内存影响之前读取，因此稍后对同一寄存器的写回无法改变这次存储使用的地址。

地址在存储之前经过预检。成功时执行一次 `1` 字节小端存储，并记录一个 relaxed 存储事件。

前索引地址是基址加位移，因此一个和同时服务于访问与发布的值。

设计要点：被访问的地址与发布的基址是同一个和，因此 `->6` 配 `SrcR` = GPR6 会发布它存储时所经过的地址。写回仍然以存储成功为前提。

<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-inputs role=inputs-outputs -->
## 编码字段与作用

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是带符号 `17` 位位移，在编码中由 3 部分组成：位 `41`..`47`、位 `23`..`27` 与位 `6`..`10`，覆盖 `-65536`..`65535` 字节。
- `RegDst` 是 `5` 位选择子。编码 `1`..`23` 写入绝对 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`，编码 `0` 与 `24`..`29` 丢弃该结果且不抑制其他影响。
- 设计要点：基址是 `SrcR`，值是 `SrcD`，位移在指令中，因此没有寄存器被花在地址上。队列槽位仍可以是基址或值，而两者都不会被消耗。

<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当存储无故障完成时，更新后的基址会发布到 `RegDst`。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcD` 可以与 `RegDst` 指定同一个寄存器。存储数据在任何目的位置影响之前读取，因此内存操作存储的是指令执行前的值，而该寄存器随后持有更新后的基址。

<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 每个地址都是整数个 `1` 字节单元，因此本形式的预检无法引发 `Fault_DataAlignment`。权限或受限内存失败会在原地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。
- 设计要点：基址寄存器在存储之前读取，因此同时也是 `RegDst` 的 `SrcR` 会把指令执行前的值贡献给地址。写回无法反馈进同一条指令。

<!-- PTO-READER-BLOCK: scalar-hl-sbi-pr-example role=example -->
## 端到端读一条编码

下面只说明如何使用本页，不增加指令行为。

- 假设 `hl.sbi.pr 5, [6, -1], ->8` 执行时 GPR6 = `0x2000`，GPR5 = `0xABCD`。
- 前索引地址是 `0x1FFF`，因此字节 `0xCD` 被存储在那里。
- GPR8 收到 `0x1FFF`，即基址加位移。
- 其他内存字节与其他寄存器都不改变，且 `TPC` 变为指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sbi.pr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sbi_pr_48_d6f48429cca5 | HL48 | 48 | 0x00000059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sbi_pr_48_d6f48429cca5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sbi_pr_48_d6f48429cca5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sbi_pr_48_d6f48429cca5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sbi_pr_48_d6f48429cca5 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sbi_pr_48_d6f48429cca5 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sbi_pr_48_d6f48429cca5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbi_pr_48_d6f48429cca5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sbi_pr_48_d6f48429cca5 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBI.PR.asl -->
```asl
readonly func InstructionContractOperation_HL_SBI_PR() => ScalarOperation
begin
    return ScalarOperation_HL_SBI_PR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBI.PR.asl -->
```asl
readonly func InstructionContractHandler_HL_SBI_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SBI_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SBI_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SBI_PR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBI_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBI_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SBI_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBI_PR()
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
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.sbi.pr SrcD, [SrcR, simm], ->{t, u, Rd}
