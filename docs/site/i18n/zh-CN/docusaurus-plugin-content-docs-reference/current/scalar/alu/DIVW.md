<!-- GENERATED FROM: asl/scalar/alu/DIVW.asl -->
# DIVW

**Normative ASL source:** `asl/scalar/alu/DIVW.asl`

DIVW computes the signed low-32-bit quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divw-purpose role=purpose -->
## DIVW 的作用

`DIVW` 是一种 32 位 L32 形式，把两个 Reg5 源的低字按有符号整数相除，并发布一个符号扩展到 `PTO_XLEN` 的结果。两个源的位 `63` 至位 `32` 都被忽略。

设计要点：助记符同时确定操作数宽度和有符号性。两个寄存器只要低字相同，即使高位字不同也会得到相同的商，因此 `DIVW` 的结果只是每个源 `32` 位的函数，而不是 `64` 位的函数。

<!-- PTO-READER-BLOCK: scalar-divw-mechanism role=mechanism -->
## 商的形成方式

执行时把 `SrcL[31:0]` 与 `SrcR[31:0]` 符号扩展到 `PTO_XLEN`，再用 `DIV` 所用的同一套全域定义规则对这两个字做除法。

- 正是这次扩展让低字成为有符号数：位 `31` 为 1 的低字在除法开始前就变成一个负的 `PTO_XLEN` 值。
- 低字除数为零时返回 `0`，而有符号最小低字除以 `-1` 返回同一个低字。

随后商被截取其低 `32` 位并再次符号扩展，因此商的位 `31` 会被复制到发布字的每一个更高位。

设计要点：正是第二次扩展让发布字始终落在 `-2147483648` 与 `2147483647` 之间。唯一在精确算术中会超出有符号 32 位范围的情形，即有符号最小低字除以 `-1`，会被该扩展折回 `-2147483648`，而不会变成正值。

<!-- PTO-READER-BLOCK: scalar-divw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数。每个源只使用位 `31` 至位 `0`，两者都按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `RegDst` 发布符号扩展后的商：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃它。

设计要点：目标始终是一个完整的 `PTO_XLEN` 字。`DIVW` 从不只写入 `32` 位，因此原本保存更宽取值的 GPR 会被整体替换，而不是部分更新。

<!-- PTO-READER-BLOCK: scalar-divw-effects role=effects -->
## 效果与顺序

两次源读取都发生在写入 `RegDst` 之前，因此与源重名的目标仍然用指令执行前的取值做除法。

结果被发布或丢弃之后，`TPC` 前进 `4` 字节。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变，除非 `RegDst` 为 `30` 或 `31`，否则也不会有任何队列项移动。

设计要点：这里选择操作数用的正是 `DIV` 所用的同一组 5 位 `SrcL` 与 `SrcR` 字段。并不存在单独的按字源映射，因此高位字是被读取后丢弃，而不是从不被寻址。

<!-- PTO-READER-BLOCK: scalar-divw-constraints role=constraints -->
## 合法性与故障边界

三个选择符各自分配了全部 `32` 个编码，且该形式除 32 位匹配与掩码之外不带任何固定位，因此 `DIVW` 没有保留的操作数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 `T` 或 `U` 源不可用在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：按字形式并不移动故障边界。源可用性检查在处理器读取任一操作数之前运行，因此发生故障的 `DIVW` 还没有检查过其源的任何一位。

<!-- PTO-READER-BLOCK: scalar-divw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `-7`、`a1` 的低 `32` 位为 `2` 时，`divw a0, a1, ->a2` 把 `-3` 写入 `a2`：绝对值相除得到 `7 / 2 = 3`，两个操作数符号不同，于是用 `0` 减去该绝对值。改变 `a0` 的高位 `32` 位不会改变结果。当 `a1` 的低字为 `0` 时商为 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divw_32_b6366c50ac8c | L32 | 32 | 0x00002057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divw_32_b6366c50ac8c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divw_32_b6366c50ac8c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divw_32_b6366c50ac8c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divw_32_b6366c50ac8c | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divw_32_b6366c50ac8c | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divw_32_b6366c50ac8c | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractOperation_DIVW() => ScalarOperation
begin
    return ScalarOperation_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVW.asl -->
```asl
readonly func InstructionContractHandler_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSignedW;
end;
pure func InstructionContractResult_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
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

- Interpret each source low 32 bits as signed, return the quotient truncated toward zero, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns zero. Signed 32-bit minimum divided by negative one returns sign-extended signed minimum.
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

- divw a0, a1, ->a2
- divw t#1, zero, ->u
