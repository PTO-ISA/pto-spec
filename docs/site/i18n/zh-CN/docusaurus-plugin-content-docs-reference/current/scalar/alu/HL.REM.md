<!-- GENERATED FROM: asl/scalar/alu/HL.REM.asl -->
# HL.REM

**Normative ASL source:** `asl/scalar/alu/HL.REM.asl`

HL.REM computes a signed XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-rem-purpose role=purpose -->
## HL.REM 的作用

`HL.REM` 是一条 48 位标量 ALU 指令，它把两个有符号 XLEN 值相除，并发布两个结果：余数通过 `RegDst0`，商通过 `RegDst1`。

除法是全定义的。除数为零以及有符号最小值除以 `-1` 都有定义结果，因此该助记符没有算术故障情形。

<!-- PTO-READER-BLOCK: scalar-hl-rem-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractQuotient_HL_REM` 与 `InstructionContractRemainder_HL_REM`，它们分别调用 `ScalarDivideSigned` 与 `ScalarRemainderSigned`。分派路径以 `signed_operation` 为真调用 `ExecuteScalarRemainderPair`；该辅助函数先算出 `quotient` 与 `remainder`，再把余数写入 `RegDst0`、把商写入 `RegDst1`。

```asm
hl.rem SrcL, SrcR, ->Dst0, Dst1
```

设计要点：`ScalarDivideSigned` 对绝对值做除法，只在两个符号不同时取负，因此商向零截断。`ScalarRemainderSigned` 是 `dividend - quotient * divisor`，这使余数带上被除数的符号，而不是除数的符号。

<!-- PTO-READER-BLOCK: scalar-hl-rem-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0`，指令切片 `[23 +: 5]`，接收余数，或丢弃它。
- `RegDst1`，指令切片 `[11 +: 5]`，接收商，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被除数。
- `SrcR`，指令切片 `[36 +: 5]`，提供除数。

两个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。编码零除数读取体系结构零 GPR，因此会选择已定义的零除数结果。

设计要点：两个目标字段相互独立，因此这一对可以丢弃其中一半、把一个写进 GPR 而把另一个推入队列，或者把两者都推入同一队列。重复推送是有定义的，因为先推余数、后推商。

<!-- PTO-READER-BLOCK: scalar-hl-rem-effects role=effects -->
## 效果与顺序

两个源都取快照，两个结果都在任一目标写入之前算出，因此与 `SrcL` 或 `SrcR` 同名的目标无法干扰这一对结果。

发布顺序是 `RegDst0` 之后 `RegDst1`：先余数，后商。如果两个字段指向同一个 GPR，商是最终值；如果两者推入同一队列，商是最新表项，余数是次新表项。

目标效果之后 `TPC` 前进 `6` 字节。`HL.REM` 不读写内存，除选定的队列推送之外，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-hl-rem-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，重复目标也合法，因此操作数合法性只可能因临时源不可用而失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在任一目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：这里没有任何操作数值会触发算术故障。除数为零时发布商 `0`、余数等于被除数；有符号最小值除以 `-1` 时发布有符号最小值作为商、余数为 `0`，因为绝对值路径是回绕而不是陷入。

<!-- PTO-READER-BLOCK: scalar-hl-rem-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 13`、`SrcR = 5` 时商为 `2`、余数为 `3`，因此 `RegDst0` 收到 `3`，`RegDst1` 收到 `2`。取 `SrcL = -7`、`SrcR = 3` 时商为 `-2`、余数为 `-1`，因此 `RegDst0` 收到 `0xFFFFFFFFFFFFFFFF`，`RegDst1` 收到 `0xFFFFFFFFFFFFFFFE`。`SrcR` 取体系结构零 GPR、`SrcL = 13` 时，`RegDst0` 收到 `13`，`RegDst1` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.rem SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_rem_48_3c13e08615aa | HL48 | 48 | 0x00004057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_rem_48_3c13e08615aa | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_rem_48_3c13e08615aa | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_rem_48_3c13e08615aa | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_rem_48_3c13e08615aa | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_rem_48_3c13e08615aa | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_rem_48_3c13e08615aa | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractOperation_HL_REM() => ScalarOperation
begin
    return ScalarOperation_HL_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REM.asl -->
```asl
readonly func InstructionContractHandler_HL_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REM(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REM(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REM(
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

- hl.rem a0, a1, ->a2, a3
- hl.rem t#1, zero, ->u, u
