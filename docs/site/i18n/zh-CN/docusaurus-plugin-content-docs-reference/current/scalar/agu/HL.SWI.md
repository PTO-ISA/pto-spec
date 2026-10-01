<!-- GENERATED FROM: asl/scalar/agu/HL.SWI.asl -->
# HL.SWI

**Normative ASL source:** `asl/scalar/agu/HL.SWI.asl`

HL.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-swi-purpose role=purpose -->
## `HL.SWI` 的作用

`HL.SWI` 是一条独立的 `48` 位标量 AGU 存储指令，带较宽的按比例缩放立即数且没有结果。它把来自 `SrcD` 的 `4` 字节小端单元写到 `SrcR` 基址加 `simm22` 位移处。

规范汇编是 `hl.swi SrcD, [SrcR, simm]`。

设计要点：本编码完全没有目的端字段，因此 `HL.SWI` 绝不会发布更新后的基址。基址与位移之和只作为这一次存储的地址存在。

<!-- PTO-READER-BLOCK: scalar-hl-swi-mechanism role=mechanism -->
## 地址与传输如何形成

译出的地址类型是立即数存储，因此 `SrcR` 是基址。符号扩展后的 `simm22` 按 `4` 缩放，并与该基址按模 `2^PTO_XLEN` 相加。

预检依次检查 `4` 字节对齐、转换、权限与有界内存。存储数据源从 `SrcD` 读取，只有整个地址都通过后才执行 `4` 字节小端存储并记录一个 relaxed 存储事件。

之后不发布任何结果：由于没有 `RegDst` 字段，指令在存储事件之后结束，`TPC` 前进 `6` 字节。

设计要点：`22` 位字段按 `4` 缩放，因此立即数以 `4` 字节单位计数，覆盖 `-8388608`..`8388604` 字节。字节位移的最低两位始终为 `0`。

<!-- PTO-READER-BLOCK: scalar-hl-swi-inputs role=inputs-outputs -->
## 编码字段与角色

- `SrcD` 提供被存储的 `4` 字节。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `SrcR` 提供基址。编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消费。
- `simm22` 为带符号数，覆盖 `-2097152`..`2097151` 个 `4` 字节单位。
- 设计要点：这里的字段名 `SrcR` 表示基址。在寄存器偏移形式中同名意味着按比例缩放的索引，而基址是 `SrcL`；由译出的地址类型决定适用哪种角色。
- 设计要点：不存在目的端选择子，因此该和只用作这次存储的地址，之后没有寄存器记录它。

<!-- PTO-READER-BLOCK: scalar-hl-swi-effects role=effects -->
## 效果、顺序与完成

基址在内存操作之前取快照，因此即使数据源就是基址寄存器，被存储的字节与地址也来自指令执行前的值。

成功尝试记录一个 relaxed 存储事件，只改变所存范围的 `4` 字节，并使 `TPC` 前进 `6` 字节。

设计要点：只有当存储范围与包含该保留的 `64` 字节粒度重叠时，存储才会作废保留。

<!-- PTO-READER-BLOCK: scalar-hl-swi-constraints role=constraints -->
## 合法性、故障与重启

- 固定位不匹配或所选 `T`/`U` 源不可用，都会在任何指令效果之前引发 `Fault_IllegalInstruction`。
- 不是 `4` 的倍数的地址会在转换之前引发 `Fault_DataAlignment`；之后的权限或有界内存失败会在原始有效地址处引发 `Fault_DataPage`。
- 故障不记录存储事件、不写字节，并让 `TPC` 停留在引发故障的指令上以便完整重发。
- 设计要点：由于位移是 `4` 的倍数而访问需要 `4` 字节对齐，有效地址的对齐性质就是基址的对齐性质；立即数无法修正未对齐的基址。

<!-- PTO-READER-BLOCK: scalar-hl-swi-example role=example -->
## 端到端读一条编码

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- 以 GPR `6` = `0x2000` 为基址、`simm` = `-2` 时，字节位移是 `-8`，地址是 `0x1FF8`。
- 以 GPR `5` = `0x0000000055667788` 作为 `SrcD` 时，写入 `0x1FF8`..`0x1FFB` 的字节是 `88 77 66 55`。
- 之后没有寄存器记录该地址，因为本编码没有目的端字段。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.swi SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_swi_48_13deb2849df5 | HL48 | 48 | 0x00002059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_swi_48_13deb2849df5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_swi_48_13deb2849df5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_swi_48_13deb2849df5 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_swi_48_13deb2849df5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_swi_48_13deb2849df5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_swi_48_13deb2849df5 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SWI.asl -->
```asl
readonly func InstructionContractOperation_HL_SWI() => ScalarOperation
begin
    return ScalarOperation_HL_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SWI.asl -->
```asl
readonly func InstructionContractHandler_HL_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SWI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.
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

- hl.swi SrcD, [SrcR, simm]
