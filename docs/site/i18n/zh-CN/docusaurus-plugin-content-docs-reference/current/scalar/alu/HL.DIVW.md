<!-- GENERATED FROM: asl/scalar/alu/HL.DIVW.asl -->
# HL.DIVW

**Normative ASL source:** `asl/scalar/alu/HL.DIVW.asl`

HL.DIVW computes a signed low-32-bit quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divw-purpose role=purpose -->
## HL.DIVW 的作用

`HL.DIVW` 是有符号成对结果的 48 位 HL48 按字形式。它把两个 Reg5 源的低字按有符号整数相除，并向 `RegDst0` 发布符号扩展后的商、向 `RegDst1` 发布符号扩展后的余数。

设计要点：两个结果都经过同一条扩展规则，但只有商可能离开有符号 32 位范围。只要除数非零，余数的绝对值就小于除数的绝对值，因此它的低字扩展回来就是精确的有符号余数。商则不同：有符号最小低字除以 `-1` 本应得到 `2147483648`，而最后的扩展发布的是 `-2147483648`。

<!-- PTO-READER-BLOCK: scalar-hl-divw-mechanism role=mechanism -->
## 两个结果的形成方式

执行时把 `SrcL[31:0]` 与 `SrcR[31:0]` 符号扩展到 `PTO_XLEN`，并从这两个字推导出这一对结果。

- 商是扩展后操作数上的有符号商，向零截断。
- 余数是同样这些扩展操作数上的 `dividend - quotient * divisor`。
- 随后每个结果被截取其低 `32` 位并符号扩展到 `PTO_XLEN`，先发布商，再发布余数。

在扩展后的操作数上计算，正是让这一对结果成为加宽到 `PTO_XLEN` 的有符号 32 位除法，而不是 `32` 位的回绕。

设计要点：当 `a0` 的低 `32` 位为 `-7`、`a1` 的低 `32` 位为 `2` 时，这一对是 `-3` 与 `-1`，任一源的高位字都不会改变它。

<!-- PTO-READER-BLOCK: scalar-hl-divw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数。每个源只使用位 `31` 至位 `0`，两者都按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `RegDst0` 发布商，`RegDst1` 发布余数；两者都使用通用映射，`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃。
- 高位字作为完整源取值的一部分被读取，随后被按字算术丢弃。

设计要点：字段布局与 `HL.DIV` 相同，因此同一组 5 位编码在两个助记符中指向相同的寄存器和队列槽位。区分 `hl.divw` 与 `hl.div` 的只有操作数宽度和解释的有符号性。

<!-- PTO-READER-BLOCK: scalar-hl-divw-effects role=effects -->
## 效果与顺序

两个结果都在任一目标效果之前算出，发布遵循编码顺序 `RegDst0` 然后 `RegDst1`。随后 `TPC` 前进 `6` 字节。

内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变，除了目标编码为 `30` 或 `31` 之外，也不会有任何队列项移动。

设计要点：当 `RegDst0` 与 `RegDst1` 指向同一个 GPR 时，按顺序的第二次写入把余数留在该寄存器中，商则丢失，因此商只能保存在另一个目标里。同一个队列也同理：较晚的压入让余数成为最新项。

<!-- PTO-READER-BLOCK: scalar-hl-divw-constraints role=constraints -->
## 合法性与故障边界

`SrcL`、`SrcR`、`RegDst0` 和 `RegDst1` 都分配了每个编码，且该 48 位形式除匹配与掩码之外不带任何固定位。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 `T` 或 `U` 源不可用在任一目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：按字形式保留有符号族的全域除数规则。低字除数为零时商为 `0`、余数为有效被除数；有符号最小低字除以 `-1` 时得到同一个低字且余数为 `0`；没有任何除数取值能到达那条要求除数非零的恢复余数法断言。

<!-- PTO-READER-BLOCK: scalar-hl-divw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `-7`、`a1` 的低 `32` 位为 `2` 时，`hl.divw a0, a1, ->a2, a3` 把 `-3` 写入 `a2`、把 `-1` 写入 `a3`，因为 `-7 - (-3 * 2)` 等于 `-1`。当 `a1` 的低字为 `0` 时商为 `0`，余数是 `a0` 低字的符号扩展。当 `a0=-8`、`a1=2` 时，这一对是 `-4` 与 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | HL48 | 48 | 0x00002057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divw_48_9048cdb3b22f | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divw_48_9048cdb3b22f | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divw_48_9048cdb3b22f | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divw_48_9048cdb3b22f | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVW.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
pure func InstructionContractQuotient_HL_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
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

- Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
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

- hl.divw a0, a1, ->a2, a3
- hl.divw t#1, zero, ->u, u
