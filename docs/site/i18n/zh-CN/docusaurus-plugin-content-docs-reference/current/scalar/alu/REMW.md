<!-- GENERATED FROM: asl/scalar/alu/REMW.asl -->
# REMW

**Normative ASL source:** `asl/scalar/alu/REMW.asl`

REMW computes the signed low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remw-purpose role=purpose -->
## REMW 的作用

`REMW` 对两个源的有符号低字做除法，并发布符号扩展到 `PTO_XLEN` 的有符号余数。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00006057`，并分派到 `ScalarRemainderSignedW`。

字形式先收窄操作数、随后加宽结果，因此能放进 `32` 位的余数会以该字的符号扩展 `64` 位值发布。

<!-- PTO-READER-BLOCK: scalar-remw-mechanism role=mechanism -->
## 字余数形成方式

`ScalarRemainderSignedW` 把 `dividend32` 绑定为 `SignExtend{PTO_XLEN}(dividend[31:0])`、把 `divisor32` 绑定为 `SignExtend{PTO_XLEN}(divisor[31:0])`，调用 `ScalarRemainderSigned(dividend32, divisor32)`，并返回 `SignExtend{PTO_XLEN}(remainder[31:0])`（`asl/scalar/model/alu/semantics.asl:90-96`）。分派路径在 `asl/scalar/model/dispatch/alu.asl:246-251` 处为 `ScalarOperation_REMW` 选择它。

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：操作数的符号扩展使 `0xFFFFFFFF` 这样的字成为被除数 `-1`。最终的符号扩展作用于已经跟随被除数符号的 `32` 位余数，因此发布的字是 `32` 位截断除法所能产生的取值的 `64` 位扩展。

设计要点：在这个辅助函数中，有符号 `32` 位最小值除以负一返回 `0`，与全宽度 `REM` 完全一致。该情形有定义答案，不会触发故障。

<!-- PTO-READER-BLOCK: scalar-remw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供被除数字，`SrcR` 提供除数字，`RegDst` 接收符号扩展后的余数。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `SrcR`，指令切片 `[20 +: 5]`：同样的五位映射；只有 `SrcR[31:0]` 参与运算。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，其低字就是零除数；答案是符号扩展后的被除数低字。

设计要点：低字为负的被除数在除法之前被扩展，因此低字为 `0xFFFFFFFF`、除数为 `2` 时，`remw` 发布 `-1`，而相同位模式下的无符号助记符发布 `1`。`remw`/`remuw` 这一对仅在这项解释上不同。

<!-- PTO-READER-BLOCK: scalar-remw-effects role=effects -->
## 效果与顺序

两个低字都在写入 `RegDst` 之前读取，因此与源同名的目标对执行前的值做除法。符号扩展后的余数发布后 `TPC` 推进 `4` 字节。

`REMW` 不访问内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、分支目标或控制流状态；唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：商被算出后即被丢弃。由于 `REMW` 没有商目标，需要同时得到两个结果的有符号字除法必须再使用一条指令。

<!-- PTO-READER-BLOCK: scalar-remw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个源编码与全部 `32` 个目标编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `REMW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：没有任何操作数组合会选择陷阱：零除数返回扩展后的被除数，有符号最小值除以负一返回 `0`。因此 `REMW` 没有依赖取值的故障路径。

<!-- PTO-READER-BLOCK: scalar-remw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0 = -7`、`a1 = 3` 时，`remw a0, a1, ->a2` 发布 `-1`，因为扩展后的被除数是 `-7`，字级商截断为 `-2`。

当 `a0 = 0x100000007`、`a1 = 2` 时只有低字参与：被除数字是 `7`，`a2` 收到 `1`。当 `a1` 的低字为 `0` 时，`a2` 收到符号扩展后的被除数字 `7`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | L32 | 32 | 0x00006057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remw_32_22659af46ec0 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remw_32_22659af46ec0 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
pure func InstructionContractResult_REMW(
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

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret each source low 32 bits as signed, return the signed remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend. Signed 32-bit minimum divided by negative one returns zero.
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

- remw a0, a1, ->a2
- remw t#1, zero, ->u
