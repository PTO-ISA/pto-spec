<!-- GENERATED FROM: asl/scalar/alu/ANDW.asl -->
# ANDW

**Normative ASL source:** `asl/scalar/alu/ANDW.asl`

ANDW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise conjunction, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ANDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andw-purpose role=purpose -->
## ANDW 的作用

`ANDW` 按与 `AND` 相同的方式准备右源，在低 `32` 位上计算合取，并把该字符号扩展到 `PTO_XLEN` 后发布。

设计要点：`ANDW` 与 `AND` 共用全部五个字段，因此程序可以在全宽掩码和字掩码之间切换而不改变操作数布局。不同的只有合取与发布的位宽。

<!-- PTO-READER-BLOCK: scalar-andw-mechanism role=mechanism -->
## 结果形成方式

`SrcRType` 变换完整的 `SrcR` 值：`00` 对 `SrcR[31:0]` 做符号扩展，`01` 对 `SrcR[31:0]` 做零扩展，`10` 对每一位取反，`11` 保持不变。`shamt` 随后把变换后的值逻辑左移 `0` 至 `31` 位。

合取在两个操作数的低 `32` 位上完成，随后结果位 `31` 被复制到发布值的 `63..32` 位。

设计要点：由于族标志把 `ANDW` 标为逻辑族，这里的 `SrcRType=10` 是按位取反，而同一个编码在 `ADDW` 中是取负。两个助记符除了运算本身不同，在这一行为上也不同。

设计要点：`SrcL` 的 `63..32` 位在合取之前就被排除，因此即使源的高字被置位，这些位也不可能保留到结果中。

<!-- PTO-READER-BLOCK: scalar-andw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。
- `SrcRType` 选择右源变换，`shamt` 给出变换后的逻辑左移量。汇编中省略后缀即编码 `SrcRType=11`。
- `RegDst` 发布符号扩展后的字结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：编码零对两个源表示读取架构零 GPR，对目标表示丢弃；`SrcRType` 的编码零选择 `.sw`，因此需要 `.not` 时必须显式编码该修饰符。

<!-- PTO-READER-BLOCK: scalar-andw-effects role=effects -->
## 效果与顺序

两个源都在写入目标之前读取，因此源与目标重名时观察到的是指令执行前的值。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`ANDW` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-andw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：四个 `SrcRType` 编码以及 `0` 至 `31` 的全部 `32` 个 `shamt` 取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：截断到 `32` 位和最后的符号扩展都不会触发故障，因此 `ANDW` 没有依赖取值的陷阱。它的整个故障边界就是编码与源可用性。

<!-- PTO-READER-BLOCK: scalar-andw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4294967295`、`SrcR=15`、`SrcRType=11`、`shamt=0` 时，`ANDW` 发布 `15`。当 `SrcL=18446744073709551615`、`SrcR=3` 时，发布值为 `3`，因为只有源的低字参与合取。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andw_32_6907ed7cec90 | L32 | 32 | 0x00002025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andw_32_6907ed7cec90 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| andw_32_6907ed7cec90 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andw_32_6907ed7cec90 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| andw_32_6907ed7cec90 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| andw_32_6907ed7cec90 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| andw_32_6907ed7cec90 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| andw_32_6907ed7cec90 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDW.asl -->
```asl
readonly func InstructionContractOperation_ANDW()
    => ScalarOperation
begin
    return ScalarOperation_ANDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDW.asl -->
```asl
readonly func InstructionContractHandler_ANDW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ANDW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ANDW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ANDW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ANDW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ANDW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_AND, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ANDW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ANDW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise conjunction with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
- Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- ANDW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andw a0, a1, ->a2
- andw t#1, u#1.not<<1, ->u
- andw zero, a0.sw, ->zero
