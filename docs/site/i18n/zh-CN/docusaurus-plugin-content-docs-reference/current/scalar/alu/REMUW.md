<!-- GENERATED FROM: asl/scalar/alu/REMUW.asl -->
# REMUW

**Normative ASL source:** `asl/scalar/alu/REMUW.asl`

REMUW computes the unsigned low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remuw-purpose role=purpose -->
## REMUW 的作用

`REMUW` 对两个源的低 `32` 位取无符号余数，并把该 `32` 位结果符号扩展到 `PTO_XLEN` 后发布。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00007057`，并分派到 `ScalarRemainderUnsignedW`。

这里发生了两次宽度变换：操作数在除法之前从 `32` 位零扩展，结果在除法之后从 `32` 位符号扩展。第二次不是无符号扩展。

<!-- PTO-READER-BLOCK: scalar-remuw-mechanism role=mechanism -->
## 字余数形成方式

`ScalarRemainderUnsignedW` 把 `dividend32` 绑定为 `ZeroExtend{PTO_XLEN}(dividend[31:0])`、把 `divisor32` 绑定为 `ZeroExtend{PTO_XLEN}(divisor[31:0])`，调用 `ScalarRemainderUnsigned(dividend32, divisor32)`，并返回 `SignExtend{PTO_XLEN}(remainder[31:0])`（`asl/scalar/model/alu/semantics.asl:74-80`）。分派路径在 `asl/scalar/model/dispatch/alu.asl:252-257` 处通过 `ScalarOperation_REMUW` 到达它。

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：操作数的零扩展使该字成为无符号：源的第 `31` 位向被除数贡献 `2147483648` 而不是符号。随后的符号扩展重新解释结果的第 `31` 位，因此无符号字余数 `0xFFFFFFFF` 会发布为 `0xFFFFFFFFFFFFFFFF`。

设计要点：由于操作数止于 `32` 位，低字相同的两个寄存器发布相同的余数，与它们的高半部无关。源的高字无法改变商或余数。

<!-- PTO-READER-BLOCK: scalar-remuw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 保存被除数，`SrcR` 保存除数，`RegDst` 接收符号扩展后的字余数。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 进入除法器。
- `SrcR`，指令切片 `[20 +: 5]`：同样的五位映射。只有 `SrcR[31:0]` 进入除法器。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR；其低字是 `0`，从而选择零除数答案。

设计要点：低字为零的除数给出的答案是符号扩展后的被除数低字，而不是零。当被除数的低字是 `0xFFFFFFFF` 时，发布的字是 `0xFFFFFFFFFFFFFFFF`，因此零除数情形并不约束发布值的大小。

<!-- PTO-READER-BLOCK: scalar-remuw-effects role=effects -->
## 效果与顺序

两个源都在写入之前读取，因此同名目标对执行前的低字做除法。符号扩展后的余数发布后 `TPC` 推进 `4` 字节。

`REMUW` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、分支目标或控制流状态。仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：字级除法丢弃商的高半部且不记录任何信息。发布的字是唯一可观察的痕迹，而且它是符号扩展的 `32` 位取值，而不是完整的无符号结果。

<!-- PTO-READER-BLOCK: scalar-remuw-constraints role=constraints -->
## 合法性与故障边界

每个 Reg5 源编码与每个 Reg5 目标编码都有定义，该形式除固定编码位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `REMUW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

被除数与除数都是全定义输入：低字为零的除数以扩展后的被除数作答，没有任何操作数组合会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-remuw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `10`、`a1` 的低 `32` 位为 `4` 时，`remuw a0, a1, ->a2` 发布 `2`。

当 `a0` 为 `0x10000000A`、`a1` 为 `4` 时，只有低字参与，因此被除数字是 `10`，`a2` 收到 `2`。当 `a1` 的低字为 `0` 时，字余数就是整个被除数字，因此 `a2` 收到 `10`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | L32 | 32 | 0x00007057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remuw_32_f10ade2f5ccb | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remuw_32_f10ade2f5ccb | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
pure func InstructionContractResult_REMUW(
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

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret each source low 32 bits as unsigned, return the unsigned remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend.
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

- remuw a0, a1, ->a2
- remuw t#1, zero, ->u
