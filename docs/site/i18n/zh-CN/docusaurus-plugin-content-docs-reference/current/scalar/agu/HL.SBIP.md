<!-- GENERATED FROM: asl/scalar/agu/HL.SBIP.asl -->
# HL.SBIP

**Normative ASL source:** `asl/scalar/agu/HL.SBIP.asl`

HL.SBIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SBIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sbip-purpose role=purpose -->
## `HL.SBIP` 的作用

`HL.SBIP` 是一条独立的 `48` 位标量 AGU 指令，从 `SrcD` 与 `SrcD1` 存出两个相邻的 `1` 字节小端单元。

规范汇编形式为 `hl.sbip SrcD, SrcD1, [SrcR, simm]`。

位移就在指令里并按字节计数，因此可以在基址寄存器的固定偏移处写入一对相邻字节，而完全不需要索引寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-sbip-mechanism role=mechanism -->
## `HL.SBIP` 如何构成地址并完成传输

位移是符号扩展后的 `simm17` 值，移位量为 `0`，加到 `SrcR` 快照上并对 `2^PTO_XLEN` 取模。

该和就是第一个地址，第二个地址是该和加 `1`。更新模式为无，因此不发布任何基址回写。

两个地址都会被预检，两个存储数据源也都会在第一次存储之前被读取。发生故障时，两个单元都不会被写入。

设计要点：`1` 字节对正好是 `16` 位目的负载，因此这种形式可以写入一条逻辑记录中两个互相独立的字节，而无需对周边字节做读-改-写。

设计要点：两个源只有在两次预检都成功之后才被读取，因此被拒绝或发生故障的尝试会让每个源寄存器与 `T` 或 `U` 队列条目都保持不变。

<!-- PTO-READER-BLOCK: scalar-hl-sbip-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcD1` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是带符号的 `17` 位位移，在编码中由三段携带：位 `41`..`47`、位 `23`..`27` 与位 `11`..`15`，覆盖 `-65536`..`65535` 字节。
- 本形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不发布更新后的基址。

设计要点：`SrcD` 与 `SrcD1` 可以指定同一个寄存器，此时两个字节都会由同一次指令执行前的读取得到相同的值。存储不会修改任何一个源。

<!-- PTO-READER-BLOCK: scalar-hl-sbip-effects role=effects -->
## 效果、快照与完成顺序

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

成功执行会按地址递增顺序记录两个 relaxed 存储事件。

在内存方面，执行成功只改变所存范围之内的字节。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

设计要点：每个源只有低 `8` 位会被写入，因此更宽的源会被静默截断。每个寄存器的其余部分不受影响。

<!-- PTO-READER-BLOCK: scalar-hl-sbip-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 每个地址都是 `1` 字节单元的整数倍，因此本形式的预检不会引发 `Fault_DataAlignment`。权限或受限内存失败会在失败单元自身的地址引发 `Fault_DataPage`：当只有第二个单元未通过边界或权限检查时，报告的是第二个地址。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。

设计要点：本形式既没有 `SrcRType` 也没有 `shamt` 字段，因此本形式没有任何字段被判定为保留；编码层面的拒绝只有固定位不匹配，以及不可用的 `T` 或 `U` 源槽位。

<!-- PTO-READER-BLOCK: scalar-hl-sbip-example role=example -->
## 非规范阅读示例

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sbip 5, 6, [7, 2]`，其中 GPR7 = `0x9000`、GPR5 = `0xAA11`、GPR6 = `0xBB22`。
- `2` 字节的位移给出两个地址 `0x9002` 与 `0x9003`。
- 字节 `0x11` 存储在 `0x9002`，字节 `0x22` 存储在 `0x9003`。
- 没有寄存器发生变化，`TPC` 变为指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sbip SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sbip_48_48a212ee655e | HL48 | 48 | 0x00000059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sbip_48_48a212ee655e | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sbip_48_48a212ee655e | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 register-offset source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBIP() => ScalarOperation
begin
    return ScalarOperation_HL_SBIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SBIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SBIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SBIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SBIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.sbip SrcD, SrcD1, [SrcR, simm]
