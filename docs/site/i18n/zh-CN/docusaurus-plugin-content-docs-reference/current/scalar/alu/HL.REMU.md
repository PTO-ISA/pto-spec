<!-- GENERATED FROM: asl/scalar/alu/HL.REMU.asl -->
# HL.REMU

**Normative ASL source:** `asl/scalar/alu/HL.REMU.asl`

HL.REMU computes an unsigned XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remu-purpose role=purpose -->
## HL.REMU 的作用

`HL.REMU` 是一条 48 位标量 ALU 指令，它把两个无符号 XLEN 值相除，并通过 `RegDst0` 发布余数、通过 `RegDst1` 发布商。

两个操作数都按无符号数值读取，因此第 `63` 位被置位的源贡献的是它的大正值，而不是负值。

<!-- PTO-READER-BLOCK: scalar-hl-remu-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractQuotient_HL_REMU` 与 `InstructionContractRemainder_HL_REMU`，它们分别调用 `ScalarDivideUnsigned` 与 `ScalarRemainderUnsigned`。分派路径以 `signed_operation` 为假调用 `ExecuteScalarRemainderPair`；该辅助函数先算出两个值，再先写余数、后写商。

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

设计要点：`ScalarRemainderUnsigned` 定义为 `dividend - MultiplyWord(quotient, divisor)`，因此除数为非零时，发布结果满足 `dividend = quotient * divisor + remainder`，且余数小于除数。除数非零时没有数值对能破坏这一恒等式。

<!-- PTO-READER-BLOCK: scalar-hl-remu-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收余数，或丢弃它。
- `RegDst1`，指令切片 `[11 +: 5]`，接收商，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被除数。
- `SrcR`，指令切片 `[36 +: 5]`，提供除数。

两个源使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，全部非消耗读取。编码零读取体系结构零 GPR。

设计要点：操作数角色由编码固定。`SrcL` 始终是被除数，`SrcR` 始终是除数，因此想要 `a / b` 与 `b / a` 的调用方需要两条指令；没有编码的交换位，也没有隐式操作数。

<!-- PTO-READER-BLOCK: scalar-hl-remu-effects role=effects -->
## 效果与顺序

两个源都取快照，两个结果都在第一次目标写入之前算出，因此重复的目标名称与源同名观察到的都是执行前的值。

`RegDst0` 先收到余数，`RegDst1` 随后收到商。在同一个 GPR 上商是最终值；在同一个队列上商是最新表项，余数是次新表项。随后 `TPC` 前进 `6` 字节，除选定的队列推送之外不触及内存或其他体系结构状态。

<!-- PTO-READER-BLOCK: scalar-hl-remu-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，重复目标也合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：无符号读取消除了有符号形式必须定义的有符号溢出拐角。除数为零仍然是全定义的：它发布商 `0`、余数等于被除数，因此 `hl.remu` 不会因操作数值触发故障。

<!-- PTO-READER-BLOCK: scalar-hl-remu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 13`、`SrcR = 5` 时商为 `2`、余数为 `3`，因此 `RegDst0` 收到 `3`，`RegDst1` 收到 `2`。取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 2` 时商为 `0x7FFFFFFFFFFFFFFF`，余数为 `1`。`SrcR` 取体系结构零 GPR 时商为 `0`，余数为被除数。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | HL48 | 48 | 0x00005057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMU(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMU(
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

- hl.remu a0, a1, ->a2, a3
- hl.remu t#1, zero, ->u, u
