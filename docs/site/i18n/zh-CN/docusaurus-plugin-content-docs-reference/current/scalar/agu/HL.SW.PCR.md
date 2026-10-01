<!-- GENERATED FROM: asl/scalar/agu/HL.SW.PCR.asl -->
# HL.SW.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SW.PCR.asl`

HL.SW.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SW-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-purpose role=purpose -->
## `HL.SW.PCR` 存储什么

`HL.SW.PCR` 是一条独立的 `48` 位标量 AGU 指令，在相对当前位置的地址上存储来自 `SrcL` 的一个小端 `4` 字节单元。

规范汇编是 `hl.sw.pcr SrcL, [<symbol>]`。

设计要点：整个地址都由 `TPC` 与位移构成，因此此形式可以相对自身位置存储，而不必把地址保存在寄存器里。

<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-mechanism role=mechanism -->
## 地址如何形成

基址是清除了 `1:0` 位的 `TPC`。编码的 `simm` 先符号扩展，再左移 `2` 位，并按 `2^PTO_XLEN` 取模相加，得到有效地址。

标度为 `2`，因此编码位移以 `4` 字节字计数，对齐后的基址与缩放后的位移都是 `4` 的倍数。

更新模式为 none，因此该存储使用计算出的地址，且没有寄存器接收结果：此形式没有 `RegDst` 字段。

预检在存储之前进行，`SrcL` 在该预检之前读取；成功时执行一次 `4` 字节小端存储并记录一个 relaxed 存储事件。

设计要点：位移以指令自身为基准度量，而 `TPC` 只在存储之后前进，因此同一份编码始终指向相对于代码的同一位置。

<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-inputs role=inputs-outputs -->
## 操作数

- `SrcL` 是 `5` 位 Reg5 源选择子：编码 `0`..`23` 选择绝对 GPR，`24`..`27` 选择 `T#1`..`T#4`，`28`..`31` 选择 `U#1`..`U#4`；队列条目被读取时不会被消耗，编码 `0` 读取架构零 GPR。

- `simm` 是 `29` 位有符号字段，分配从 `-268435456` 到 `268435455` 的全部值；编码字节位移是该值乘以 `4`，编码零表示零位移而不是省略。

- 此形式没有 `RegDst` 字段，因此没有寄存器接收结果，也不会发布更新后的基址。

设计要点：`simm` 分配所有有符号 `29` 位字位移，因此可达的字节位移从 `-1073741824` 到 `1073741820`，没有任何编码值被保留。

<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-effects role=effects -->
## 影响与顺序

`SrcL` 在存储之前读取，基址由 `TPC` 提供，因此被存储的单元是指令执行前的值。

执行成功时记录一个 relaxed 存储事件，只改变该单元的 `4` 字节。

当所存范围与有效保留的 `64` 字节粒度块重叠时，该保留被作废；保留所在的粒度块未被本次存储触及的，仍然有效。

存储完成之后 `TPC` 前进 `6` 字节。被拒绝或发生故障的尝试不会退休。

设计要点：`SrcL` 只有低 `4` 字节写入内存；高 `32` 位被丢弃，`SrcL` 本身保持原值。

<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-constraints role=constraints -->
## 对齐、故障与重启

- 有效地址必须是 `4` 的倍数，而它始终如此：基址的 `1:0` 位已清零，缩放后的位移是 `4` 的倍数。对齐预检仍然运行，但对此形式不可能引发 `Fault_DataAlignment`。

- 固定位不匹配，或源选择子指向不可用的 `T` 或 `U` 条目，会在任何指令影响之前于 `PC` 处引发 `Fault_IllegalInstruction`。

- 发生故障时不记录存储事件：内存与所有寄存器保持指令执行前的值，`TPC` 不前进，恢复时重新计算地址、预检与存储。

设计要点：即使编码完全合法，被引用的范围也可能落在有效区域之外，因此相对当前位置的存储仍依赖权限与有界内存检查。

<!-- PTO-READER-BLOCK: scalar-hl-sw-pcr-example role=example -->
## 示例

该示例只演示地址计算；精确行为仍由当前 ASL 与指令契约定义。

- `hl.sw.pcr 20, [3]` 在 `TPC` = `0x1006` 处执行，GPR20 = `0xdeadbeef`。

- `TPC` 的 `1:0` 位被清除，因此基址是 `0x1004`；位移 `3` 乘以 `4` 得到 `12`，有效地址是 `0x1010`。

- 该存储按地址递增顺序把 `0xef`、`0xbe`、`0xad`、`0xde` 写到 `0x1010` 到 `0x1013`。

- `SrcL` 保持 `0xdeadbeef`，存储在 `TPC` 前进 `6` 字节到 `0x100c` 之前完成。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sw.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_pcr_48_8f8900dfac6b | HL48 | 48 | 0x00002069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_pcr_48_8f8900dfac6b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_pcr_48_8f8900dfac6b | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sw_pcr_48_8f8900dfac6b | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sw_pcr_48_8f8900dfac6b | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SW_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SW_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SW_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SW_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SW_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SW_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SW_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SW_PCR()
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
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
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

- hl.sw.pcr SrcL, [<symbol>]
