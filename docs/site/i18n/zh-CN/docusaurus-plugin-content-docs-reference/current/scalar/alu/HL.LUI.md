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

`HL.LUI` 把常数物化到目标字的高半部分。它不编码任何源寄存器。译码重组 `imm` 立即数，把它零扩展到 `PTO_XLEN`，左移 `32` 位，并通过 `RegDst` 发布结果。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：结果的第 `31:0` 位永远为零，编码携带的常数只从第 `32` 位向上出现。`hl.lui 1, ->a0` 写入的是 `4294967296` 而不是 `1`，因此需要非零低半部分的值必须由另一条指令提供。

<!-- PTO-READER-BLOCK: scalar-hl-lui-mechanism role=mechanism -->
## 高半部分的形成方式

立即数以两个片段到达；一个携带值位 `19:0`，另一个携带第 `31:20` 位。重组出的 `32` 位模式被零扩展成一个完整的 `PTO_XLEN` 字，然后左移 `32` 位。

设计要点：移位作用在零扩展后的值上，因此全部 `32` 个编码位都落到第 `63:32` 位，而第 `31:0` 位对每个编码都保持为零，全 1 立即数也不例外。立即数自身的第 `31` 位成为结果第 `63` 位，因此以 1 开头的常数会产生最高位被置位的字：`hl.lui 4294967295, ->a0` 写入 `18446744069414584320`。

<!-- PTO-READER-BLOCK: scalar-hl-lui-inputs role=inputs-outputs -->
## 输入与目标

- `imm` 携带将占据结果第 `63:32` 位的 `32` 位模式。
- `RegDst` 发布移位后的字：编码 `1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`imm=0` 物化数值 `0`，因此这个编码是一次已定义性明确的零发布，而不是被省略的操作数。`hl.lui 0, ->a0` 写入 `0`，并且像本形式的其他任何编码一样，仍然让 `TPC` 前进 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-lui-effects role=effects -->
## 效果与顺序

立即数在目标效果之前重组，途中不读取任何寄存器和队列项。`U` 或 `T` 目标压入会让移位后的字成为该队列的下标 `1`，并丢弃原来位于下标 `4` 的项；GPR 目标只覆盖那一个寄存器。

发布之后是 `TPC` 前进 `6` 字节。`HL.LUI` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-lui-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `RegDst` 编码，以及 `32` 位立即数字段的全部 `4294967296` 个模式。

有两处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。两者都先于目标效果和 `TPC` 前进。

设计要点：本形式不编码源选择符，因此寄存器形式的源不可用拒绝不可能发生在本助记符上，而且每个目标编码都已分配。于是 `HL.LUI` 的编码只会因固定位或适用性检查所读的指令束状态而被拒绝。

`HL.LUI` 不增加算术异常：把零扩展的 `32` 位值左移 `32` 位既不会丢位，也不会溢出。

<!-- PTO-READER-BLOCK: scalar-hl-lui-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`hl.lui 1, ->a0` 写入 `4294967296`，在第 `32` 位放一个 1，并让低字保持为零。`hl.lui 4294967295, ->t` 压入 `18446744069414584320`，它的低半部分为零，最高位被置位。
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
