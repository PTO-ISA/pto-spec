<!-- GENERATED FROM: asl/scalar/alu/HL.DIV.asl -->
# HL.DIV

**Normative ASL source:** `asl/scalar/alu/HL.DIV.asl`

HL.DIV computes a signed XLEN quotient/remainder pair from source snapshots, then publishes quotient followed by remainder.

## Normative identity {#PTO-INST-SCALAR-HL-DIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-div-purpose role=purpose -->
## HL.DIV 的作用

`HL.DIV` 是一种 48 位 HL48 形式，带有两个源字段和两个目标字段。它把两个 Reg5 操作数按有符号 `PTO_XLEN` 整数相除，并通过 `RegDst0` 发布商、通过 `RegDst1` 发布余数。

设计要点：这是用同一对源读取返回两半结果的拼写。`DIV` 发布相同的商并丢弃余数，`REM` 用自己的一次读取推导余数；`HL.DIV` 则从同一对快照推导出这两个发布值。

<!-- PTO-READER-BLOCK: scalar-hl-div-mechanism role=mechanism -->
## 商与余数的形成方式

执行时读取 `SrcL` 与 `SrcR`，先算出两个结果，然后才发布它们。

- 商是完整操作数的有符号商，向零截断，也就是 `DIV` 发布的那个值。
- 余数是同样这两个操作数上的 `dividend - quotient * divisor`，因此它带有被除数的符号，并且在除数非零时其绝对值小于除数的绝对值。

随后按编码顺序发布：`RegDst0` 接收商，`RegDst1` 接收余数。

设计要点：因为余数是由商这个字推导出来的，而不是来自一次独立除法，所以在 `PTO_XLEN` 二进制补码算术下，这一对结果始终满足 `dividend = quotient * divisor + remainder`。当 `a0=-13`、`a1=5` 时，该恒等式给出 `-13 - (-2 * 5) = -3`，因此余数是 `-3` 而不是 `3`。

<!-- PTO-READER-BLOCK: scalar-hl-div-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数。两者都使用 Reg5 源映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不消费队列项。
- `RegDst0` 接收商，`RegDst1` 接收余数。两者各自使用 Reg5 目标映射：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃。
- 四个字段都是必需的编码字段，因此 `HL.DIV` 没有只返回商或只返回余数的拼写。

设计要点：重复目标是合法的，发布顺序决定最终结果。当 `RegDst0` 与 `RegDst1` 编码为同一个 GPR 时，余数是该寄存器的最终取值；当两者都编码为 `30` 或都编码为 `31` 时，余数成为该队列的最新项，商成为次新项。

<!-- PTO-READER-BLOCK: scalar-hl-div-effects role=effects -->
## 效果与顺序

两个源都在第一个目标效果之前被读取，两个结果也都在此之前算出，因此与源重名的目标仍然用指令执行前的取值做除法。

两次发布之后，`TPC` 前进 `6` 字节，即该 48 位形式的长度。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

设计要点：一侧丢弃只抑制那一侧。当 `RegDst0` 携带丢弃编码时商被丢掉，而余数仍然写入 `RegDst1`，该指令执行的源读取和算术与同时发布两个值的成对形式完全相同。

<!-- PTO-READER-BLOCK: scalar-hl-div-constraints role=constraints -->
## 合法性与故障边界

两个源和两个目标都分配了 Reg5 空间的每个编码，且该 48 位形式除匹配与掩码之外没有额外的固定位约束，因此 `HL.DIV` 没有保留的选择符取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；所选 `T` 或 `U` 源不可用在任一目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：源可用性检查在读取源之前运行，而且没有任何目标编码会被拒绝，因此两次发布之间不可能发生故障。就目标效果而言这一对是全有或全无：两次写入要么都发生，要么都不发生。

<!-- PTO-READER-BLOCK: scalar-hl-div-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=-13`、`a1=5` 时，`hl.div a0, a1, ->a2, a3` 把 `-2` 写入 `a2`、把 `-3` 写入 `a3`，因为余数是按 `-13 - (-2 * 5)` 计算的。当 `SrcR` 编码为零时，除数是架构零 GPR，因此商为 `0`，余数为被除数 `-13`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.div SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_div_48_e8ff1fc1cb98 | HL48 | 48 | 0x00000057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_div_48_e8ff1fc1cb98 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_div_48_e8ff1fc1cb98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_div_48_e8ff1fc1cb98 | RegDst0 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_div_48_e8ff1fc1cb98 | RegDst1 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_div_48_e8ff1fc1cb98 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_div_48_e8ff1fc1cb98 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | quotient Reg5 destination or discard |
| RegDst1 | remainder Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractOperation_HL_DIV() => ScalarOperation
begin
    return ScalarOperation_HL_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.DIV.asl -->
```asl
readonly func InstructionContractHandler_HL_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
pure func InstructionContractQuotient_HL_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSigned(
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

- Interpret the selected operands as signed values, compute both quotient and remainder using the fixed total division rules.
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

- hl.div a0, a1, ->a2, a3
- hl.div t#1, zero, ->u, u
