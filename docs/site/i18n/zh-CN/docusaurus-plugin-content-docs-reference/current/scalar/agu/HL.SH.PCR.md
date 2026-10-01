<!-- GENERATED FROM: asl/scalar/agu/HL.SH.PCR.asl -->
# HL.SH.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SH.PCR.asl`

HL.SH.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-purpose role=purpose -->
## `HL.SH.PCR` 存储什么

`HL.SH.PCR` 是一条独立的 `48` 位标量 AGU 指令，在相对当前位置的地址上存储来自 `SrcL` 的一个小端 `2` 字节单元。

规范汇编是 `hl.sh.pcr SrcL, [<symbol>]`。

设计要点：地址仅由 `TPC` 与位移构成，因此相对当前位置的存储不需要基址寄存器，也不会被其他指令改动的寄存器影响。

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-mechanism role=mechanism -->
## 地址如何形成

基址是清除了 `1:0` 位的 `TPC`。编码的 `simm` 先符号扩展，再左移 `2` 位，并按 `2^PTO_XLEN` 取模相加，得到有效地址。

标度为 `2`，因此编码位移以 `4` 字节字计数；相加之前清除 `TPC` 的 `1:0` 位，使整个地址始终是 `4` 的倍数。

更新模式为 none，因此该存储使用计算出的地址，且没有寄存器接收结果：此形式没有 `RegDst` 字段。

预检在存储之前进行，`SrcL` 在该预检之前读取；成功时执行一次 `2` 字节小端存储并记录一个 relaxed 存储事件。

设计要点：位移是有符号的 `29` 位字数，因此可达的字节位移在以对齐后的指令地址为中心、从 `-1073741824` 到 `1073741820` 的范围内。

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-inputs role=inputs-outputs -->
## 操作数

- `SrcL` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `simm` 是 `29` 位有符号字段，分配从 `-268435456` 到 `268435455` 的全部值；编码字节位移是该值乘以 `4`，编码零表示零位移而不是省略。

- 此形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不会发布更新后的基址。

设计要点：`simm` 分配完整的 `-268435456..268435455` 取值域，编码零就是零位移，因此不需要另设一个表示“无位移”的编码。

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-effects role=effects -->
## 影响与顺序

`SrcL` 在存储之前读取，基址由 `TPC` 提供，因此被存储的单元是指令执行前的值。

执行成功时记录一个 relaxed 存储事件，只改变该单元的 `2` 字节。

当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

存储完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcL` 只有低 `2` 字节写入内存，`SrcL` 本身不变，因此该存储是纯粹的内存影响。

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-constraints role=constraints -->
## 对齐、故障与重启

- 有效地址必须是 `2` 的倍数，而它始终如此：基址的 `1:0` 位已清零，缩放后的位移是 `4` 的倍数。对齐预检仍然运行，但对此形式不可能引发 `Fault_DataAlignment`。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- 发生故障时不记录存储事件：内存与所有寄存器保持指令执行前的值，`TPC` 不前进，恢复时重新计算地址、预检与存储。

设计要点：基址的 `1:0` 位已清零，位移又按 `4` 缩放，因此有效地址始终是 `4` 的倍数，此形式的对齐预检不可能引发 `Fault_DataAlignment`。

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.sh.pcr 20, [3]` 在 `TPC` = `0x1006` 处执行，GPR20 = `0xbeef`。

- `TPC` 的 `1:0` 位被清除，因此基址是 `0x1004`；位移 `3` 乘以 `4` 得到 `12`，有效地址是 `0x1010`。

- 该存储按地址递增顺序把 `0xef`、`0xbe` 写到 `0x1010` 到 `0x1011`。

- `SrcL` 保持 `0xbeef`，存储在 `TPC` 前进 `6` 字节到 `0x100c` 之前完成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sh.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | HL48 | 48 | 0x00001069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sh_pcr_48_705ea4062d0b | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sh_pcr_48_705ea4062d0b | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SH.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SH.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SH_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SH_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sh.pcr SrcL, [<symbol>]
