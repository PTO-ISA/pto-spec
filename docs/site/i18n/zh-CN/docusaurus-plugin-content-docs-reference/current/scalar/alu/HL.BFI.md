<!-- GENERATED FROM: asl/scalar/alu/HL.BFI.asl -->
# HL.BFI

**Normative ASL source:** `asl/scalar/alu/HL.BFI.asl`

HL.BFI copies a low source byte field into a wrapping byte interval of a snapshotted base value and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-HL-BFI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-bfi-purpose role=purpose -->
## HL.BFI 的作用

`HL.BFI` 是一条 48 位标量 ALU 指令。它把源值从低位开始的连续位插入基值中选定的闭合回绕区间；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后把源值从低位开始的连续位插入基值中选定的闭合回绕区间，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择基值。
- `SrcR` 是 5 位字段，通过 Reg5 选择插入位。
- `immr` 是 6 位字段，编码闭合区间的首个目标位。
- `imms` 是 6 位字段，编码闭合区间的最后目标位。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值只通过 `RegDst` 按当前标量目标映射发布；`immr` 与 `imms` 用于选择插入区间，并不是发布目标。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 6 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-constraints role=constraints -->
## 合法性与故障边界

位域选择可从位 63 回绕到位 0；宽度与起点的精确编码含义由下方生成的默认值和合法性表给出。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `HL.BFI` 示例说明：基值 `0`、插入源 `0x7`、`immr=2` 与 `imms=4` 产生结果 `0x1c`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | HL48 | 48 | 0x0000204d000e / 0xfe00707f000f | [{"field":"immr","operator":"one-of","values":[0,1,2,3,4,5,6,7]},{"field":"imms","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | immr | 6 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":6}] |
| hl_bfi_48_8adfd476aacc | imms | 6 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | 0–31 | none | none | Reg5 base source | Encoded zero reads the architectural zero GPR base. |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | 0–31 | none | none | Reg5 insertion source | Encoded zero reads the architectural zero GPR insertion source. |
| hl_bfi_48_8adfd476aacc | immr | 6 | 0–7 | none | 8–63 | inserted byte count N minus one | Encoded zero selects a one-byte field (N=1). |
| hl_bfi_48_8adfd476aacc | imms | 6 | 0–7 | none | 8–63 | destination byte offset M | Encoded zero begins insertion at destination byte zero (M=0). |

- `hl_bfi_48_8adfd476aacc.immr` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `hl_bfi_48_8adfd476aacc.imms` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 base source |
| SrcR | Reg5 insertion source |
| immr | inserted byte count N minus one |
| imms | destination byte offset M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractByteCount_HL_BFI(encoded_immr: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_immr) + 1;
end;

pure func InstructionContractByteOffset_HL_BFI(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;

pure func InstructionContractResult_HL_BFI(
    base: Word,
    source: Word,
    byte_offset: integer {0..7},
    byte_count: integer {1..8})
    => Word
begin
    return InsertByteField(
        base,
        source,
        byte_offset,
        byte_count);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.
- immr encodes byte count N minus one in the assigned range 0 through 7. imms encodes destination byte offset M in the assigned range 0 through 7.
- When M plus N exceeds eight, destination byte selection wraps through byte seven to byte zero. Source bytes are consumed in ascending order from byte zero.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- immr values 0 through 7 encode N=1 through 8 bytes and imms values 0 through 7 encode M=0 through 7; all larger six-bit values are reserved.

## State effects

- Snapshot the base and insertion sources. Copy the low N source bytes into N destination bytes beginning at byte M, wrapping modulo eight destination bytes; preserve every unselected base byte.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- An imms or immr encoding above 7, or an unavailable selected T/U source, raises Fault_IllegalInstruction before source reads, destination effect, or TPC advance. Both sources are preflighted even when their encoded values are equal.
- HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- hl.bfi a0, a1, 4, 4, ->a2
- hl.bfi t#1, u#1, 7, 2, ->t
- hl.bfi a0, zero, 0, 8, ->a0
