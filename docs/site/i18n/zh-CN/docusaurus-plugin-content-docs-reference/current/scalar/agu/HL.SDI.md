<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.asl -->
# HL.SDI

**Normative ASL source:** `asl/scalar/agu/HL.SDI.asl`

HL.SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdi-purpose role=purpose -->
## `HL.SDI` 做什么

`HL.SDI` 是一条独立的 `48` 位标量 AGU 指令，它把 `SrcD` 的一个 `8` 字节小端序单元存储到相对 `SrcR` 基址的有符号 `simm22` 位移处。

规范汇编形式是 `hl.sdi SrcD, [SrcR, simm]`。

设计要点：位移按 `8` 缩放，因此该编码字段以 `8` 字节单元计数，其 `22` 位可达范围变成 `-2097152`..`2097151` 个单元，即 `-16777216`..`16777208` 字节。缩放是去乘这个计数，而不是去加宽字段。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-mechanism role=mechanism -->
## 地址与传输如何形成

位移是符号扩展后的 `simm22` 左移 `3` 位，并按 `2^PTO_XLEN` 取模加到 `SrcR` 的快照上。基址在任何内存影响之前被读取，因此之后对同一寄存器的回写不可能改变本次存储所用的地址。

地址在存储之前被预检。成功时执行一次 `8` 字节小端序存储，并记录一个 relaxed 存储事件。

因为更新模式为无，本形式没有 `RegDst` 字段，也不发布任何内容。基址与被存储的值是它唯一读取的寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-inputs role=inputs-outputs -->
## 编码字段与效果

- `SrcD` 是 `5` 位 Reg5 选择子，提供存储数据。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 作为基址，使用同样的 `5` 位 Reg5 域，因此基址可以是绝对 GPR，也可以是 `T` 或 `U` 队列槽位。
- `simm22` 是有符号 `22` 位位移，以 `8` 字节单元计，在编码中由三段承载，即第 `41`..`47` 位、第 `23`..`27` 位与第 `6`..`15` 位，覆盖 `-2097152`..`2097151` 个单元。
- 本形式没有 `RegDst` 字段，因此没有寄存器收到结果，也不发布更新后的基址。

设计要点：带缩放的位移永远不可能把基址移出 `8` 字节边界，因为每个单元步长都是 `8` 的倍数。访问是否对齐因此完全由基址取值决定，而与位移无关。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-effects role=effects -->
## 影响、顺序与完成

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

在内存方面，执行成功只改变所存范围之内的字节。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

内存操作完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcD` 的 `8` 个字节全部属于本次传输，因此低字节落在该单元的最低地址，并且不发生截断。比该单元更宽的存储在此无法表达；载荷恰好就是一个寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 未按 `8` 字节对齐的地址会在翻译或权限检查之前引发 `Fault_DataAlignment`。之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。

设计要点：本形式不携带 `SrcRType`，也不携带 `shamt` 字段，因此本形式没有任何字段被判定为保留；在地址形成之前，编码层面的拒绝只有固定位不匹配与不可用的 `T`、`U` 源槽位。

<!-- PTO-READER-BLOCK: scalar-hl-sdi-example role=example -->
## 完整读一条编码

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sdi 5, [6, -1]`，GPR6 = `0x2000`，GPR5 = `0x0807060504030201`。
- 位移是 `-1` 个单元，即 `-8`，因此有效地址是 `0x1FF8`。
- `0x1FF8` 按 `8` 字节对齐，因此预检通过，`8` 个字节 `01` `02` `03` `04` `05` `06` `07` `08` 按地址递增顺序写入该处。
- 没有寄存器改变，`TPC` 变为该指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdi SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_48_3203094081da | HL48 | 48 | 0x00003059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_48_3203094081da | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_48_3203094081da | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_48_3203094081da | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_48_3203094081da | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_48_3203094081da | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_48_3203094081da | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI() => ScalarOperation
begin
    return ScalarOperation_HL_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.sdi SrcD, [SrcR, simm]
