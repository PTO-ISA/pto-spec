<!-- GENERATED FROM: asl/scalar/alu/HL.MULU.asl -->
# HL.MULU

**Normative ASL source:** `asl/scalar/alu/HL.MULU.asl`

HL.MULU computes an unsigned 128-bit scalar product and publishes its low half followed by its high half.

## Normative identity {#PTO-INST-SCALAR-HL-MULU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-mulu-purpose role=purpose -->
## HL.MULU 的作用

`HL.MULU` 是一条 48 位标量 ALU 指令。它计算完整的无符号 128 位乘积，并拆分低、高两半；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后计算完整的无符号 128 位乘积，并拆分低、高两半，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0` 是 5 位字段，选择乘积或累加结果低半部的 Reg5 目标。
- `RegDst1` 是 5 位字段，选择乘积或累加结果高半部的 Reg5 目标。
- `SrcL` 是 5 位字段，通过 Reg5 选择左乘数或加法操作数。
- `SrcR` 是 5 位字段，通过 Reg5 选择右乘数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-effects role=effects -->
## 效果与顺序

所有结果都在发布前计算完成。随后按编码顺序（`RegDst0`, `RegDst1`）更新目标；目标重复指向同一寄存器或队列时也采用这一顺序。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 6 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-hl-mulu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `HL.MULU` 示例说明：源值 `6` 与 `7` 产生低部结果 `42`；宽结果对形式还产生高部结果 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.mulu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mulu_48_85efdc81e8fc | HL48 | 48 | 0x00001047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mulu_48_85efdc81e8fc | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mulu_48_85efdc81e8fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_mulu_48_85efdc81e8fc | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_mulu_48_85efdc81e8fc | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_mulu_48_85efdc81e8fc | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_mulu_48_85efdc81e8fc | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractOperation_HL_MULU() => ScalarOperation
begin
    return ScalarOperation_HL_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MULU.asl -->
```asl
readonly func InstructionContractHandler_HL_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MULU(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideUnsigned(left, right);
end;

pure func InstructionContractLow_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MULU(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MULU(left, right)[127:64];
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Zero-extend both XLEN sources into an unsigned 128-bit product.
- Snapshot every source and compute the complete 128-bit result before destinations. Publish bits 63:0 to RegDst0, then bits 127:64 to RegDst1. Duplicate destinations are legal; the second high result is final/newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the low result to RegDst0, publish the high result to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.mulu srcl, srcr, ->dst0, dst1
