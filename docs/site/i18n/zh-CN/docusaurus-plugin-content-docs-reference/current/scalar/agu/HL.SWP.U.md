<!-- GENERATED FROM: asl/scalar/agu/HL.SWP.U.asl -->
# HL.SWP.U

**Normative ASL source:** `asl/scalar/agu/HL.SWP.U.asl`

HL.SWP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SWP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swp-u-purpose role=purpose -->
## HL.SWP.U 的作用

`HL.SWP.U` 是一条独立的 `48` 位 AGU 指令；它形成寄存器偏移地址，并存储两个相邻且对齐的小端 `4` 字节值。

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-mechanism role=mechanism -->
## 地址与内存机制

`HL.SWP.U` 按 `SrcRType` 转换 `SrcR`，不再缩放，并将结果按 `2^PTO_XLEN` 取模后加到快照中的 `SrcL` 基址。

该指令先预检两个相邻的 `4` 字节地址，再按地址递增顺序存储两个已快照的数据值。

此形式不回写基址寄存器；有效地址只供所选内存操作使用。

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供基址；`SrcR` 提供寄存器偏移量；`SrcRType` 提供偏移量转换方式。其中的 Reg5 源 `SrcD`、`SrcD1`、`SrcL`、`SrcR` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `SrcD` 提供第一个存储值；`SrcD1` 提供第二个存储值。
- `SrcRType` 的 `0..3` 均已分配；先执行所选转换，再执行该形式的固定缩放。

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

两个地址全部通过预检后，成功执行按地址顺序记录两个 relaxed 存储事件，只在完整预检后更新重叠保留状态，并将 `TPC` 前移 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-constraints role=constraints -->
## 对齐、故障与重启

每个有效地址都必须满足 `4` 字节对齐。未对齐会在地址转换前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不会记录成功的内存事件，也不会产生部分内存、目的端或回写效果；待处理回写保持不变，故障 `TPC` 保留以供完整重发。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-hl-swp-u-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、偏移源为不经转换的 `4`，并采用固定左移 `0` 位，对齐位移就是 `4`，基址加位移为 `0x104`。内存访问使用 `0x104`。两个地址全部通过预检后，第二个 `4` 字节存储使用 `0x108`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | HL48 | 48 | 0x00006049001e / 0x00007ffff83f | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swp_u_48_c244a576be8e | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swp_u_48_c244a576be8e | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swp_u_48_c244a576be8e | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_swp_u_48_c244a576be8e | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `hl_swp_u_48_c244a576be8e.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SWP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SWP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SWP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SWP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SWP_U()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SWP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWP_U()
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
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.swp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]
