<!-- GENERATED FROM: asl/scalar/alu/ADDW.asl -->
# ADDW

**Normative ASL source:** `asl/scalar/alu/ADDW.asl`

ADDW applies the selected right-source transformation before its encoded logical left shift, performs fixed-width word addition, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addw-purpose role=purpose -->
## ADDW 的作用

`ADDW` 按与 `ADD` 完全相同的方式准备右源，在 32 位宽上把它加到左源上，并把低 `32` 位符号扩展到 `PTO_XLEN` 后发布。

设计要点：`ADDW` 保留 `ADD` 的全部字段布局，包括 `SrcRType` 和 `shamt`，只改变最终加法的位宽。因此同时需要全宽运算和字运算的程序使用两个助记符、一套操作数模型，而不是两种指令形状。

<!-- PTO-READER-BLOCK: scalar-addw-mechanism role=mechanism -->
## 结果形成方式

右源首先在 `PTO_XLEN` 位宽上准备：`SrcRType` 应用 `00`（对 `SrcR[31:0]` 做符号扩展）、`01`（对 `SrcR[31:0]` 做零扩展）、`10`（取负）或 `11`（不变），随后 `shamt` 把该值逻辑左移 `0` 至 `31` 位。

只有在此之后，两个操作数才被截断到各自的低 `32` 位。`ScalarBinaryW` 按 `2^32` 取模把 `SrcL[31:0]` 与准备好的右字相加，并对结果做符号扩展，因此发布值的 `63..32` 位是结果位 `31` 的副本。

设计要点：变换和移位发生在截断之前，因此 `.sw`、`.uw` 和 `.neg` 看到的是完整的 `64` 位右源，被移出的位只由字加法丢弃。

设计要点：`SrcL` 的 `63..32` 位被忽略，因此对大的操作数而言 `ADDW` 并不是 `ADD` 的低半部分。`addw a0, zero, ->a0` 是对 `a0[31:0]` 做符号扩展的规范写法。

<!-- PTO-READER-BLOCK: scalar-addw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 和 `SrcR` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。
- `SrcRType` 选择右源变换，`shamt` 给出变换后的逻辑左移量。汇编中省略后缀即编码 `SrcRType=11`。
- `RegDst` 发布符号扩展后的字结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：编码零对 `SrcL` 和 `SrcR` 表示读取架构零 GPR，对 `RegDst` 表示丢弃；`SrcRType` 的编码零选择 `.sw`，`shamt` 的编码零表示不移位。

<!-- PTO-READER-BLOCK: scalar-addw-effects role=effects -->
## 效果与顺序

两个源都在写入目标之前读取，因此源与目标重名时使用指令执行前的值。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`ADDW` 不访问内存；除 `RegDst` 选中的那一次 `T` 或 `U` 压入外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词和控制流状态。

<!-- PTO-READER-BLOCK: scalar-addw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：四个 `SrcRType` 编码以及 `0` 至 `31` 的全部 `32` 个 `shamt` 取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：字加法不会触发故障。超过 `2^32` 的和保留低 `32` 位并对其做符号扩展，因此不存在溢出陷阱，`ADDW` 也不需要饱和控制。

<!-- PTO-READER-BLOCK: scalar-addw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4294967295`、`SrcR=1`、`SrcRType=11`、`shamt=0` 时，字和回绕为 `0`，`ADDW` 发布 `0`；而同样的操作数在 `ADD` 下发布 `4294967296`。当 `SrcL=3`、`SrcR=3` 且 `SrcRType=10` 时，准备好的右值为 `-3`，发布出的字为 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | L32 | 32 | 0x00000025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| addw_32_a27109fe30fc | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addw_32_a27109fe30fc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| addw_32_a27109fe30fc | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| addw_32_a27109fe30fc | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| addw_32_a27109fe30fc | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| addw_32_a27109fe30fc | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractOperation_ADDW()
    => ScalarOperation
begin
    return ScalarOperation_ADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractHandler_ADDW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ADDW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ADDW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ADDW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ADDW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ADDW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_ADD, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ADDW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_ADDW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .neg, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ADDW uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, add SrcL at 32-bit width modulo 2^32, and sign-extend the low 32-bit result to XLEN.
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

- ADDW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addw a0, a1, ->a2
- addw t#1, u#1.neg<<1, ->u
- addw zero, a0.sw, ->zero
