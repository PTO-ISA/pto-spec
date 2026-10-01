<!-- GENERATED FROM: asl/scalar/agu/HL.SDIP.U.asl -->
# HL.SDIP.U

**Normative ASL source:** `asl/scalar/agu/HL.SDIP.U.asl`

HL.SDIP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 8-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SDIP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-purpose role=purpose -->
## `HL.SDIP.U` 的作用

`HL.SDIP.U` 是一条独立的 `48` 位标量 AGU 指令，从 `SrcD` 与 `SrcD1` 存出两个相邻的 `8` 字节小端单元。

规范汇编形式为 `hl.sdip.u SrcD, SrcD1, [SrcR, simm]`。

设计要点：`.u` 后缀去掉了隐含的 `8` 字节缩放，因此位移按字节计数，对子中的第二个单元正好比第一个高 `8` 字节。两个单元因此相邻，无需编码任何间隙。

<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-mechanism role=mechanism -->
## `HL.SDIP.U` 如何构成地址并完成传输

位移是符号扩展后的 `simm17` 值，移位量为 `0`，加到 `SrcR` 快照上并对 `2^PTO_XLEN` 取模。

该和就是第一个地址，第二个地址是该和加 `8`。更新模式为无，因此不发布任何基址回写。

两个地址都会被预检，两个存储数据源也都会在第一次存储之前被读取。发生故障时，两个单元都不会被写入。

设计要点：一条指令可以从两个寄存器填充一个 `16` 字节的目的窗口。由于两个单元先被预检，第二个单元上的失败会在第一个单元被写入之前报告。

设计要点：两个源只有在两次预检都成功之后才被读取，因此被拒绝或发生故障的尝试会让每个源寄存器与 `T` 或 `U` 队列条目都保持不变。

<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-inputs role=inputs-outputs -->
## 编码字段及其选择的对象

- `SrcD` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcD1` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `SrcR` 是 `5` 位 Reg5 选择子。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗。
- `simm17` 是带符号的 `17` 位位移，在编码中由三段携带：位 `41`..`47`、位 `23`..`27` 与位 `11`..`15`，覆盖 `-65536`..`65535` 字节。
- 本形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不发布更新后的基址。

设计要点：两个地址都必须满足 `8` 字节对齐规则，而由于二者恰好相差 `8`，两次预检在对齐上总是一致。对齐的基址让两个单元都保持对齐；不对齐的基址会先在较低地址上失败。

<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-effects role=effects -->
## 效果、快照与完成顺序

所有标量源都在任何内存或目的位置影响之前取快照，因此同时被目的位置指定的源仍然贡献指令执行前的值。

成功执行会按地址递增顺序记录两个 relaxed 存储事件。

在内存方面，执行成功只改变所存范围之内的字节。当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

设计要点：每个源的全部 `8` 字节都是传输内容，因此每个单元的低字节落在该单元的最低地址处。不存在截断。

<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配，或源编码选中不可用的 `T` 或 `U` 槽位，会在任何指令影响之前引发 `Fault_IllegalInstruction`。
- 不对齐的 `8` 字节地址会在翻译或权限之前引发 `Fault_DataAlignment`。之后的权限或受限内存失败会在失败单元自身的地址引发 `Fault_DataPage`：当只有第二个单元未通过边界或权限检查时，报告的是第二个地址。
- 发生故障时不记录存储事件，内存与目的寄存器保持不变，`TPC` 停留在引发故障的指令上。恢复会从头重新计算快照、地址、预检与存储。

设计要点：位移会让两个预检地址一起移动，因此不对齐的基址会同时使两个单元不对齐，报告的故障地址是两者中较低的那个。两个单元的任何字节都不会被写入。

<!-- PTO-READER-BLOCK: scalar-hl-sdip-u-example role=example -->
## 非规范阅读示例

下面只说明如何使用本页，不增加指令行为。

- 取 `hl.sdip.u 20, 21, [3, 16]`，其中 GPR3 = `0x4000`、GPR20 = `0x0807060504030201`、GPR21 = `0x1817161514131211`。
- 位移是 `16` 字节，因此两个地址为 `0x4010` 与 `0x4018`。
- 两者都是 `8` 字节对齐，因此这对存储把 `0x0807060504030201` 写入 `0x4010`，把 `0x1817161514131211` 写入 `0x4018`。
- 没有寄存器发生变化，`TPC` 变为指令地址加 `6`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sdip.u SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdip_u_48_3260b03bb762 | HL48 | 48 | 0x00007059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdip_u_48_3260b03bb762 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdip_u_48_3260b03bb762 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sdip_u_48_3260b03bb762 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdip_u_48_3260b03bb762 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdip_u_48_3260b03bb762 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_u_48_3260b03bb762 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_u_48_3260b03bb762 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_u_48_3260b03bb762 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDIP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDIP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDIP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SDIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SDIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SDIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDIP_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDIP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDIP_U()
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
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- The pair addresses are address and address plus 8; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 8-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sdip.u SrcD, SrcD1, [SrcR, simm]
