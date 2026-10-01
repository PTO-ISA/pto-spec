<!-- GENERATED FROM: asl/scalar/alu/HL.DIVU.asl -->
# HL.DIVU

**Normative ASL source:** `asl/scalar/alu/HL.DIVU.asl`

HL.DIVU computes a unsigned XLEN quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-divu-purpose role=purpose -->
## HL.DIVU 的作用

`HL.DIVU` 是无符号的 48 位 HL48 成对形式。它把两个 Reg5 操作数按无符号 `PTO_XLEN` 整数读取，并依次通过 `RegDst0` 发布商、通过 `RegDst1` 发布余数。

设计要点：`HL.DIVU` 与 `HL.DIV` 共用同一套字段布局，只在助记符和 48 位编码的固定匹配位上不同，因此无符号解释属于被执行的指令字，而不属于某个操作数取值或模式字段。

<!-- PTO-READER-BLOCK: scalar-hl-divu-mechanism role=mechanism -->
## 成对结果的形成方式

执行时读取两个源，算出两个结果，然后按编码顺序发布它们。

- 除数为零时商为 `0`，余数就是被除数本身，因此这一对仍然满足 `dividend = quotient * divisor + remainder`。
- 除数非零时，商是两个完整操作数的无符号商，余数是 `dividend - quotient * divisor`，它严格小于除数。

商先送往 `RegDst0`，余数随后送往 `RegDst1`。

设计要点：余数是商留下来的差值，而不是另一个单独取整的值。`13` 除以 `5` 得到 `2` 与 `3` 这一对，`7` 除以 `7` 得到 `1` 与 `0`；该恒等式对编码能表达的每一对操作数都成立。

<!-- PTO-READER-BLOCK: scalar-hl-divu-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数，按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不消费队列项。
- `RegDst0` 发布商，`RegDst1` 发布余数。每个目标独立使用通用映射：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃。
- `SrcL`、`SrcR`、`RegDst0` 和 `RegDst1` 都是必需的编码字段，因此既不能省略操作数，也不能省略目标。

设计要点：两个目标相互独立，因此一条指令可以把 GPR 写入与队列压入混用，一侧的丢弃编码也不会影响另一侧。指定源选择器的目标编码是合法别名：两个源先被快照，因此只有在两次源读取发生之后，才会覆盖该寄存器或队列槽。

<!-- PTO-READER-BLOCK: scalar-hl-divu-effects role=effects -->
## 效果与顺序

两个结果都来自同一对源快照，而且都只在算术完成之后才发布。随后 `TPC` 前进 `6` 字节。

内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变，除非目标编码为 `30` 或 `31`，否则也不会有任何队列项移动。

设计要点：当两个目标都压入同一个队列时，压入遵循编码顺序，因此由 `RegDst1` 压入的余数是最新项，由 `RegDst0` 压入的商是次新项。因此在 `T#1` 可用时，`hl.divu t#1, zero, ->u, u` 把余数留在 `U#1`，把商留在 `U#2`。

<!-- PTO-READER-BLOCK: scalar-hl-divu-constraints role=constraints -->
## 合法性与故障边界

两个源和两个目标都分配了每个编码，重复的目标编码也是合法的，因此 `HL.DIVU` 没有保留的选择符取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 `T` 或 `U` 源不可用在任一目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：没有任何除数取值会引发故障。除数为零时有已定义的输出：商为 `0`、余数为被除数；除数非零时走的是单结果形式 `DIVU` 所用的同一个带保护的循环，因此成对形式没有增加陷阱路径。

<!-- PTO-READER-BLOCK: scalar-hl-divu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=13`、`a1=5` 时，`hl.divu a0, a1, ->a2, a3` 把 `2` 写入 `a2`、把 `3` 写入 `a3`。当 `SrcR` 编码为零时，除数是架构零 GPR，因此商为 `0`、余数为 `13`。当 `a0=7`、`a1=7` 时，这一对是 `1` 与 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.divu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | HL48 | 48 | 0x00001057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_divu_48_597acda29e08 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_divu_48_597acda29e08 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_divu_48_597acda29e08 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_divu_48_597acda29e08 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_divu_48_597acda29e08 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_divu_48_597acda29e08 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractOperation_HL_DIVU() => ScalarOperation
begin
    return ScalarOperation_HL_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIVU.asl -->
```asl
readonly func InstructionContractHandler_HL_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
pure func InstructionContractQuotient_HL_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
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

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules.
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

- hl.divu a0, a1, ->a2, a3
- hl.divu t#1, zero, ->u, u
