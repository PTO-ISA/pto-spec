<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.U.asl -->
# HL.SDI.U

**Normative ASL source:** `asl/scalar/agu/HL.SDI.U.asl`

HL.SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-purpose role=purpose -->
## `HL.SDI.U` 做什么

`HL.SDI.U` 是一条独立的 `48` 位标量 AGU 指令，它把来自 `SrcD` 的 `8` 字节小端单元存储在相对 `SrcR` 基址的带符号 `simm22` 位移处。

规范汇编是 `hl.sdi.u SrcD, [SrcR, simm]`。

设计要点：`.u` 后缀去掉了`hl.sdi`、`hl.sdi.po` 与 `hl.sdi.pr` 携带的隐式 `8` 字节比例，因此本形式按字节计数。更宽的 `22` 位字段正是为更细的步长付出的代价：它仍然达到 `-2097152`..`2097151` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-mechanism role=mechanism -->
## 地址与传输如何形成

位移是带符号扩展的 `simm22` 值，位移量为 `0`，并与 `SrcR` 快照按模 `2^PTO_XLEN` 相加。基址在任何内存影响之前读取，因此稍后对同一寄存器的写回无法改变这次存储使用的地址。

地址在存储之前经过预检。成功时执行一次 `8` 字节小端存储，并记录一个 relaxed 存储事件。

由于更新模式是 none，本形式没有 `RegDst` 字段，也不发布任何结果。基址与值是它读取的唯一寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-inputs role=inputs-outputs -->
## 编码字段与作用

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm22` 是带符号 `22` 位位移，在编码中由 3 部分组成：位 `41`..`47`、位 `23`..`27` 与位 `6`..`15`，覆盖 `-2097152`..`2097151` 字节。
- 本形式没有 `RegDst` 字段，因此没有寄存器收到结果，也不发布更新后的基址。
- 设计要点：按字节细分的位移可以到达该窗口内的任何字节偏移，因此本形式可以存入紧凑结构。`8` 字节对齐规则仍然适用于该和所产生的任何地址。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcD` 的全部 `8` 字节都是传输内容，因此最低字节落在该单元的最低地址。不存在截断。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 未对齐的 `8` 字节地址在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或受限内存失败会在原地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。
- 设计要点：不带比例的立即数加上任意基址可能落在 `8` 字节边界之外，指令会把它报告为 `Fault_DataAlignment`，而不是把地址取整。需要保证对齐存储的程序必须自己保持基址对齐。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-u-example role=example -->
## 端到端读一条编码

下面只说明如何使用本页，不增加指令行为。

- 假设 `hl.sdi.u 5, [6, -1]` 执行时 GPR6 = `0x2000`，GPR5 = `0x0807060504030201`。
- 地址是 `0x1FFF`，它不是 `8` 字节对齐的。
- 因此预检引发 `Fault_DataAlignment`，且没有任何字节被写入。
- 也没有寄存器改变，且 `TPC` 停留在引发故障的指令上。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdi.u SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | HL48 | 48 | 0x00007059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_u_48_d9597eeba6b4 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_u_48_d9597eeba6b4 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_u_48_d9597eeba6b4 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_u_48_d9597eeba6b4 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_U()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.sdi.u SrcD, [SrcR, simm]
