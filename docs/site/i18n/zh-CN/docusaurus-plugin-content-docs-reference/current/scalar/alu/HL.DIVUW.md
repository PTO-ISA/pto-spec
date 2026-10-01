<!-- GENERATED FROM: asl/scalar/alu/HL.DIVUW.asl -->
# HL.DIVUW

**Normative ASL source:** `asl/scalar/alu/HL.DIVUW.asl`

HL.DIVUW computes a unsigned low-32-bit quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divuw-purpose role=purpose -->
## HL.DIVUW 的作用

`HL.DIVUW` 是把两个 Reg5 源的低字按无符号整数相除的 48 位 HL48 成对形式。它向 `RegDst0` 发布符号扩展后的商、向 `RegDst1` 发布符号扩展后的余数。

设计要点：操作数是无符号的，而发布字是符号扩展的，因此这一对结果中任何一半在 `PTO_XLEN` 下都可能看起来是负的。低字被除数为 `4294967295`、除数为 `1` 时商为 `-1`，只有读取低 `32` 位的消费者才能还原无符号取值。

<!-- PTO-READER-BLOCK: scalar-hl-divuw-mechanism role=mechanism -->
## 两个结果的形成方式

执行时把 `SrcL[31:0]` 与 `SrcR[31:0]` 零扩展到 `PTO_XLEN`，并从这两个字计算两个结果。

- 商是零扩展后操作数的无符号商。
- 余数是 `dividend - quotient * divisor`，因此只要除数非零，它就小于除数。

随后每个结果被截取其低 `32` 位并符号扩展到 `PTO_XLEN`：商先送往 `RegDst0`，余数随后送往 `RegDst1`。

设计要点：该扩展同样作用于余数，而当除数大于被除数时余数就可能带位 `31`，因为此时商为 `0`、余数就是被除数的低字。当低字被除数为 `4000000000`、除数为 `4294967295` 时，`hl.divuw a0, a1, ->a2, a3` 发布商 `0` 和余数 `-294967296`。

<!-- PTO-READER-BLOCK: scalar-hl-divuw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数。两者都按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，并且每个源只有低 `32` 位进入除法器。
- `RegDst0` 接收商，`RegDst1` 接收余数。每个目标都使用通用映射：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃。
- 读取源从不消费 `T` 或 `U` 项；只有目标编码为 `30` 或 `31` 才会改变队列。

设计要点：读取源从不移除 `T` 或 `U` 项，而目标编码 `30` 或 `31` 会追加一项。每个目标各自施加，复用源选择器的目标只有在两个快照完成之后才会写该寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-divuw-effects role=effects -->
## 效果与顺序

两个源都被读取，两个结果都在第一个目标效果之前算出。商发布到 `RegDst0`，随后余数发布到 `RegDst1`，然后 `TPC` 前进 `6` 字节。

内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。没有任何东西记录截断，余数也只存在于 `RegDst1`。

设计要点：发布顺序只能通过重名观察到。当 `RegDst0` 与 `RegDst1` 编码为同一个 GPR 时，余数是该寄存器的最终内容；当两者都编码为同一个队列时，余数是最新项；两个目标互不相同时，顺序没有可见影响。

<!-- PTO-READER-BLOCK: scalar-hl-divuw-constraints role=constraints -->
## 合法性与故障边界

四个选择符都分配了每个编码，重复目标是合法的，且 48 位编码没有额外的固定位约束，因此没有为该助记符保留任何选择符取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 `T` 或 `U` 源不可用在任一目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：除数取值是全域定义的。低字除数为 `0` 时商为 `0`、余数为被除数低字的符号扩展，而它本身也可能为负，并且没有任何除数取值会引发故障。

<!-- PTO-READER-BLOCK: scalar-hl-divuw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `10`、`a1` 的低 `32` 位为 `4` 时，`hl.divuw a0, a1, ->a2, a3` 把 `2` 写入 `a2`、把 `2` 写入 `a3`。当低字被除数为 `4294967295`、除数为 `2` 时，这一对是 `2147483647` 与 `1`；当低字被除数为 `4000000000`、除数为 `4294967295` 时，这一对是 `0` 与 `-294967296`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | HL48 | 48 | 0x00003057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divuw_48_9ebe516091b8 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divuw_48_9ebe516091b8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divuw_48_9ebe516091b8 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divuw_48_9ebe516091b8 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divuw_48_9ebe516091b8 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divuw_48_9ebe516091b8 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVUW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVUW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
pure func InstructionContractQuotient_HL_DIVUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsignedW(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
- A zero divisor returns quotient zero and the effective dividend as remainder. Signed minimum divided by negative one returns signed minimum quotient and zero remainder.
- Publish RegDst0 quotient first, then RegDst1 remainder. If both destinations name one GPR, remainder is final; if both push one queue, remainder is newest and quotient is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish quotient to RegDst0, publish remainder to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.divuw a0, a1, ->a2, a3
- hl.divuw t#1, zero, ->u, u
