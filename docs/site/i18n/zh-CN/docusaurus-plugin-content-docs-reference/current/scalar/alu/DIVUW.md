<!-- GENERATED FROM: asl/scalar/alu/DIVUW.asl -->
# DIVUW

**Normative ASL source:** `asl/scalar/alu/DIVUW.asl`

DIVUW computes the unsigned low-32-bit quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divuw-purpose role=purpose -->
## DIVUW 的作用

`DIVUW` 把两个 Reg5 源的低字按无符号整数相除，并发布一个 `PTO_XLEN` 字。低字被零扩展，取值范围是 `0` 到 `4294967295`，随后商从位 `31` 做符号扩展。

设计要点：最后一步是符号扩展而不是零扩展。无符号商 `4294967295` 的位 `31` 为 1，因此当低字被除数为 `4294967295`、除数为 `1` 时，`divuw a0, a1, ->a2` 发布 `-1`，尽管计算出的无符号商已是这两个操作数所能产生的最大值。

<!-- PTO-READER-BLOCK: scalar-divuw-mechanism role=mechanism -->
## 商的形成方式

执行时把 `SrcL[31:0]` 与 `SrcR[31:0]` 零扩展到 `PTO_XLEN`，用无符号全域定义规则对这两个字做除法，再对商的低 `32` 位做符号扩展。

- 正是先对操作数做零扩展才让低字成为无符号数：源的位 `31` 贡献的是 `2147483648` 而不是符号。
- 低字除数为零时返回 `0`，而 `0` 的位 `31` 为 0，因此这种情况下发布字就是 `0`。

该机制对每一对操作数都是一致的：一次除法，随后一次符号扩展。

设计要点：因为操作数止于 `32` 位，无符号商不可能超过 `4294967295`。发布字的 `64` 位仍然全都有定义，只是其中低 `32` 位承载无符号商，高位重复商的位 `31`。

<!-- PTO-READER-BLOCK: scalar-divuw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数，两者都按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。每个源只有低 `32` 位进入除法器。
- `RegDst` 发布这一个结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃它。

设计要点：希望取回无符号商的消费者必须自己清除高位。`DIVUW` 的目标是一个完整的 `PTO_XLEN` 字，该形式没有提供零扩展的目标变体。

<!-- PTO-READER-BLOCK: scalar-divuw-effects role=effects -->
## 效果与顺序

两次源读取都发生在写入 `RegDst` 之前，因此与源重名的目标仍然用指令执行前的低字做除法。

随后该字被发布，`TPC` 前进 `4` 字节。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变；一次成功的 `DIVUW` 唯一可能造成的队列移动，是由 `30` 或 `31` 目标选择的那一次压入。

设计要点：`DIVUW` 不记录任何数值状态。符号扩展和被丢弃的余数都不留痕迹，因此发布字是该指令结果唯一可观察的地方。

<!-- PTO-READER-BLOCK: scalar-divuw-constraints role=constraints -->
## 合法性与故障边界

`SrcL`、`SrcR` 和 `RegDst` 的每个编码都已分配，因此没有为该助记符保留任何选择符取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`，所选 `T` 或 `U` 源不可用在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：这里的除数取值是全域定义的。低字除数恰好当 `SrcR[31:0]` 为零时为零，而该情形以 `0` 作答而不是引发故障，因此这个无符号助记符没有由操作数选择的陷阱路径。

<!-- PTO-READER-BLOCK: scalar-divuw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `10`、`a1` 的低 `32` 位为 `4` 时，`divuw a0, a1, ->a2` 把 `2` 写入 `a2`。当 `a0` 的低 `32` 位全为 1、`a1` 的低 `32` 位为 `1` 时，无符号商为 `4294967295`，位 `31` 为 1，发布字为 `-1`。把 `a1` 的低字设为 `0` 则发布 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divuw_32_9c9470ef8982 | L32 | 32 | 0x00003057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divuw_32_9c9470ef8982 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divuw_32_9c9470ef8982 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divuw_32_9c9470ef8982 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divuw_32_9c9470ef8982 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divuw_32_9c9470ef8982 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divuw_32_9c9470ef8982 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVUW.asl -->
```asl
readonly func InstructionContractOperation_DIVUW() => ScalarOperation
begin
    return ScalarOperation_DIVUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVUW.asl -->
```asl
readonly func InstructionContractHandler_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsignedW;
end;
pure func InstructionContractResult_DIVUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret each source low 32 bits as unsigned, return the unsigned quotient, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns zero.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- divuw a0, a1, ->a2
- divuw t#1, zero, ->u
