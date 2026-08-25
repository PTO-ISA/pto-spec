<!-- GENERATED FROM: asl/scalar/alu/HL.LUI.asl -->
# HL.LUI

**Normative ASL source:** `asl/scalar/alu/HL.LUI.asl`

HL.LUI places its split 32-bit immediate in result bits 63:32 and clears result bits 31:0.

## Normative identity {#PTO-INST-SCALAR-HL-LUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lui-purpose role=purpose -->
## HL.LUI 的作用

`HL.LUI` 是一条 48 位标量 ALU 指令。它把分段编码的 32 位立即数放入结果位 63:32，并清零位 31:0；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-lui-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后把分段编码的 32 位立即数放入结果位 63:32，并清零位 31:0，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-hl-lui-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 结果目标，或丢弃结果。
- `imm` 是 32 位字段，携带放入结果位 `63:32` 的分段 32 位值。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-hl-lui-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 6 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-lui-constraints role=constraints -->
## 合法性与故障边界

物化、移动或扩展按固定位宽获得总定义，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在状态效果前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-hl-lui-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `HL.LUI` 示例说明：立即数 `1` 在结果位 `32` 放置一，并清零低字。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lui imm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | HL48 | 48 | 0x00000017000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lui_48_255991889818 | imm | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lui_48_255991889818 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_lui_48_255991889818 | imm | 32 | 0–4294967295 | none | none | split 32-bit immediate placed in result bits 63:32 | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| imm | split 32-bit immediate placed in result bits 63:32 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LUI.asl -->
```asl
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUpper;
end;

pure func InstructionContractResult_HL_LUI(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUpper(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes unsigned immediate placement in result bits 63:32 and the common explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble imm from its two encoded pieces, zero-extend it to XLEN, shift it left by 32, and clear result bits 31:0.
- Publish the complete XLEN result through the common Reg5 destination map. Only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Reassemble the complete encoded immediate before the destination effect.
- Publish the upper-half result, then advance TPC by six bytes.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.lui imm, ->{t, u, rd}
