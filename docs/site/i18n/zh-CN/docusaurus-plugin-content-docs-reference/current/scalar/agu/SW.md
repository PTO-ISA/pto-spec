<!-- GENERATED FROM: asl/scalar/agu/SW.asl -->
# SW

**Normative ASL source:** `asl/scalar/agu/SW.asl`

SW snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-purpose role=purpose -->
## SW 的作用

`SW` 是一条独立的 `32` 位 AGU 指令；它形成寄存器偏移地址，并存储一个对齐的小端 `4` 字节值。

<!-- PTO-READER-BLOCK: scalar-sw-mechanism role=mechanism -->
## 地址与内存机制

`SW` 先按 `SrcRType` 转换 `SrcR`，再将结果乘以 `4`，并按 `2^PTO_XLEN` 取模后加到快照中的 `SrcL` 基址。

完成全部预检后，该指令从已快照的存储数据源执行一次小端 `4` 字节存储。

此形式不回写基址寄存器；有效地址只供所选内存操作使用。

<!-- PTO-READER-BLOCK: scalar-sw-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供基址；`SrcR` 提供寄存器偏移量；`SrcRType` 提供偏移量转换方式。其中的 Reg5 源 `SrcD`、`SrcL`、`SrcR` 使用完整编码域：`0..23` 选择 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且读取不会消费队列项。
- `SrcD` 提供存储数据。
- `SrcRType` 的 `0..3` 均已分配；先执行所选转换，再执行该形式的固定缩放。

<!-- PTO-READER-BLOCK: scalar-sw-effects role=effects -->
## 效果与顺序

所有显式和隐式标量源都在内存或目的端效果之前完成快照，因此别名观察到的是指令执行前的值。

成功执行会记录一个 relaxed 存储事件，使重叠保留失效但保留不重叠的保留，并将 `TPC` 前移 `4` 字节。

<!-- PTO-READER-BLOCK: scalar-sw-constraints role=constraints -->
## 对齐、故障与重启

每个有效地址都必须满足 `4` 字节对齐。未对齐会在地址转换前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始地址引发 `Fault_DataPage`。

发生故障时不会记录成功的内存事件，也不会产生部分内存、目的端或回写效果；待处理回写保持不变，故障 `TPC` 保留以供完整重发。

固定比特不匹配、字段取保留值或所选 `T`/`U` 源不可用，都会在指令效果之前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-sw-example role=example -->
## 非规范地址示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

若基址为 `0x100`、偏移源为不经转换的 `2`，并采用固定左移 `2` 位，偏移量就是 `8`，基址加偏移量为 `0x108`。内存访问使用 `0x108`。若地址对齐且权限允许，指令在该地址存储 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw SrcD, [SrcL, SrcR<{.sw,.uw}><<2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | L32 | 32 | 0x00002049 / 0x00007fff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

- `sw_32_28ad317b1b41.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractOperation_SW() => ScalarOperation
begin
    return ScalarOperation_SW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractHandler_SW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW()
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

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- sw SrcD, [SrcL, SrcR<{.sw,.uw}><<2]
