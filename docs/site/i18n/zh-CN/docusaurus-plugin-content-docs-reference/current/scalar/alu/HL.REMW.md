<!-- GENERATED FROM: asl/scalar/alu/HL.REMW.asl -->
# HL.REMW

**Normative ASL source:** `asl/scalar/alu/HL.REMW.asl`

HL.REMW computes a signed low-32-bit remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remw-purpose role=purpose -->
## HL.REMW 的作用

`HL.REMW` 是一条 48 位标量 ALU 指令，它把两个源的有符号低字相除，并通过 `RegDst0` 发布余数、通过 `RegDst1` 发布商，两者都被重新扩展到 XLEN。

`SrcL[31:0]` 与 `SrcR[31:0]` 在除法之前先做符号扩展，每个 `32` 位结果在发布之前再做一次符号扩展。

<!-- PTO-READER-BLOCK: scalar-hl-remw-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractQuotient_HL_REMW` 与 `InstructionContractRemainder_HL_REMW`，它们分别调用 `ScalarDivideSignedW` 与 `ScalarRemainderSignedW`。这些辅助函数对低字做符号扩展、执行除法，并返回 `32` 位结果的 `SignExtend{PTO_XLEN}`。分派路径以 `signed_operation` 为真调用 `ExecuteScalarRemainderPairW`，它先写余数、后写商。

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

设计要点：加宽发生在除法的两侧，而第二次加宽是符号扩展。因此字形式中等于 `0xFFFFFFFF` 的商会发布为 `0xFFFFFFFFFFFFFFFF`，而不是 `0x00000000FFFFFFFF`。

<!-- PTO-READER-BLOCK: scalar-hl-remw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收符号扩展后的余数，或丢弃它。
- `RegDst1`，指令切片 `[11 +: 5]`，接收符号扩展后的商，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被除数；只有 `31:0` 位参与。
- `SrcR`，指令切片 `[36 +: 5]`，提供除数；只有 `31:0` 位参与。

两个源都使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，非消耗读取。编码零读取体系结构零 GPR。

设计要点：由于源先被截断，低字相同的两个寄存器在 `HL.REMW` 下发布同一对结果，无论它们的高半部是什么。窄形式是对该操作的完整描述，而不是 XLEN 除法的预览。

<!-- PTO-READER-BLOCK: scalar-hl-remw-effects role=effects -->
## 效果与顺序

两个低字都取快照，两个结果都在任一写入之前算出，因此重复目标与源同名观察到的都是执行前的值。

先写 `RegDst0` 的余数，再写 `RegDst1` 的商，这决定了重复 GPR 或重复队列推送发布什么：商最新，余数次新。

目标效果之后 `TPC` 前进 `6` 字节。不访问内存，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-hl-remw-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，重复目标也合法，因此操作数合法性只可能因临时源不可用而失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：零除数规则在收窄之后依然成立。字除数为零时发布商 `0`、余数等于 `SignExtend(dividend[31:0])`，因此字形式的有效被除数是扩展后的低字，而不是整个寄存器。

<!-- PTO-READER-BLOCK: scalar-hl-remw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = -7`、`SrcR = 3` 时字除法给出商 `-2`、余数 `-1`，因此 `RegDst0` 收到 `SignExtend(0xFFFFFFFF)` = `0xFFFFFFFFFFFFFFFF`，`RegDst1` 收到 `SignExtend(0xFFFFFFFE)` = `0xFFFFFFFFFFFFFFFE`。取 `SrcL = 0x100000007`、`SrcR = 2` 时只有低字参与：被除数字为 `7`，商字为 `3`，`RegDst0` 收到 `1`，`RegDst1` 收到 `3`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | HL48 | 48 | 0x00006057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remw_48_3acb485d39a7 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remw_48_3acb485d39a7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remw_48_3acb485d39a7 | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remw_48_3acb485d39a7 | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remw_48_3acb485d39a7 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remw_48_3acb485d39a7 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMW() => ScalarOperation
begin
    return ScalarOperation_HL_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPairW;
end;
pure func InstructionContractQuotient_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMW(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMW(
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

- hl.remw a0, a1, ->a2, a3
- hl.remw t#1, zero, ->u, u
