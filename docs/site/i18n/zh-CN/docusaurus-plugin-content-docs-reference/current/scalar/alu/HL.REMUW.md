<!-- GENERATED FROM: asl/scalar/alu/HL.REMUW.asl -->
# HL.REMUW

**Normative ASL source:** `asl/scalar/alu/HL.REMUW.asl`

HL.REMUW computes an unsigned low-32-bit remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remuw-purpose role=purpose -->
## HL.REMUW 的作用

`HL.REMUW` 是一条 48 位标量 ALU 指令，它把两个源的无符号低字相除，并通过 `RegDst0` 发布余数、通过 `RegDst1` 发布商，两者都被重新扩展到 XLEN。

操作数做的是零扩展的字，但每个 `32` 位结果在发布之前做符号扩展，因此第 `31` 位被置位的结果字会以高位全为 1 的 XLEN 值到达目标。

<!-- PTO-READER-BLOCK: scalar-hl-remuw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractQuotient_HL_REMUW` 与 `InstructionContractRemainder_HL_REMUW`，它们分别调用 `ScalarDivideUnsignedW` 与 `ScalarRemainderUnsignedW`。两者都对两个低字做零扩展、执行除法，并返回 `32` 位结果的 `SignExtend{PTO_XLEN}`。分派路径以 `signed_operation` 为假调用 `ExecuteScalarRemainderPairW`，先写余数再写商。

```asm
hl.remuw SrcL, SrcR, ->Dst0, Dst1
```

设计要点：除法两侧的扩展方式不同。输入按无符号加宽，结果按有符号加宽，因此被除数字为 `0xFFFFFFFF`、除数字为 `1` 时，`hl.remuw` 发布的商是 `0xFFFFFFFFFFFFFFFF`，读作 `-1`，尽管除法本身是无符号的。

<!-- PTO-READER-BLOCK: scalar-hl-remuw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收符号扩展后的余数，或丢弃它。
- `RegDst1`，指令切片 `[11 +: 5]`，接收符号扩展后的商，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被除数；只有 `31:0` 位参与。
- `SrcR`，指令切片 `[36 +: 5]`，提供除数；只有 `31:0` 位参与。

两个源都使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，每个表项保持原位。编码零读取体系结构零 GPR。

设计要点：商与余数的目标是两个独立编码字段，因此可以丢弃其中一个而发布另一个。丢弃一个结果不会改变通过另一个发布的值。

<!-- PTO-READER-BLOCK: scalar-hl-remuw-effects role=effects -->
## 效果与顺序

两个低字都在任一写入之前读取，两个结果都在第一次写入之前完整，因此源与目标同名不会破坏任何一个值。

余数先发布到 `RegDst0`，商随后发布到 `RegDst1`；重复的 GPR 最终保存商，重复的队列推送把商放在最新位置、把余数放在次新位置。

写入完成后 `TPC` 前进 `6` 字节。内存与其他任何体系结构状态都不改变。

<!-- PTO-READER-BLOCK: scalar-hl-remuw-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，重复目标也合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：无符号字除法完全没有算术故障情形。除数字为零时发布商 `0`、余数为 `SignExtend(dividend[31:0])`，它的高位跟随被除数字的第 `31` 位，而不是除法的符号。

<!-- PTO-READER-BLOCK: scalar-hl-remuw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 13`、`SrcR = 5` 时商字为 `2`、余数字为 `3`，因此 `RegDst0` 收到 `3`，`RegDst1` 收到 `2`。取 `SrcL = 0xFFFFFFFF`、`SrcR = 1` 时商字为 `0xFFFFFFFF`，因此 `RegDst1` 收到 `0xFFFFFFFFFFFFFFFF`，`RegDst0` 收到 `0`。`SrcR` 取体系结构零 GPR、`SrcL = 0xFFFFFFFF` 时余数为 `SignExtend(0xFFFFFFFF)` = `0xFFFFFFFFFFFFFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | HL48 | 48 | 0x00007057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remuw_48_26ea6e70f2fc | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remuw_48_26ea6e70f2fc | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remuw_48_26ea6e70f2fc | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remuw_48_26ea6e70f2fc | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMUW() => ScalarOperation
begin
    return ScalarOperation_HL_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPairW;
end;
pure func InstructionContractQuotient_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMUW(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMUW(
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
- Publish RegDst0 remainder first, then RegDst1 quotient. If both destinations name one GPR, quotient is final; if both push one queue, quotient is newest and remainder is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish remainder to RegDst0, publish quotient to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.remuw a0, a1, ->a2, a3
- hl.remuw t#1, zero, ->u, u
