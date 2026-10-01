<!-- GENERATED FROM: asl/scalar/alu/REM.asl -->
# REM

**Normative ASL source:** `asl/scalar/alu/REM.asl`

REM computes the signed XLEN remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-rem-purpose role=purpose -->
## REM 的作用

`REM` 把两个完整的 `PTO_XLEN` 源当作有符号补码整数，并发布有符号除法的余数。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00004057`。这里没有商目标，也没有编码模式：助记符确定了有符号性、操作数宽度与余数结果。

`REM` 与 `DIV` 基于同一个有符号除法计算；`REM` 发布差值 `dividend - quotient * divisor`（`asl/scalar/model/alu/semantics.asl:59-64`）。

<!-- PTO-READER-BLOCK: scalar-rem-mechanism role=mechanism -->
## 余数形成方式

分派路径调用 `ScalarRemainderSigned(left, right)`，两个完整的 `PTO_XLEN` 源都通过 Reg5 映射读取（`asl/scalar/model/dispatch/alu.asl:234-239`）。该辅助函数对零除数返回未改变的被除数；否则用 `ScalarDivideSigned` 计算向零截断的商并返回 `dividend - quotient * divisor`。

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

设计要点：由于商向零截断，余数取被除数的符号，而不是除数的符号。`-7` 除以 `3` 发布 `-1`，而 `7` 除以 `-3` 发布 `1`。

设计要点：这两种特殊情形都是全定义的答案，而不是故障。零除数返回完整的被除数。有符号最小值除以负一时也返回 `0`：辅助函数比较的是绝对值，最小值的绝对值就是它自身的位模式，因此商回绕为最小值，乘积 `quotient * divisor` 与被除数相互抵消。

`REM` 不会留下任何宽中间乘积：只有余数被发布，商随辅助函数的局部绑定一起被丢弃。

<!-- PTO-READER-BLOCK: scalar-rem-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供被除数，`SrcR` 提供除数，`RegDst` 接收余数。三者都是五位 Reg5 字段。

- `SrcL`，指令切片 `[15 +: 5]`：被除数；`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。
- `SrcR`，指令切片 `[20 +: 5]`：除数，使用同样的五位映射。零除数由辅助函数给出答案，而不是触发故障。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它就是那个已定义答案为零除数的情形，其答案是未改变的被除数。

设计要点：`RegDst` 的编码零丢弃余数，但仍然执行除法并仍然推进 `TPC`。因此零除数规则只能通过目标被观察到，被丢弃的目标会把它完全隐藏。

<!-- PTO-READER-BLOCK: scalar-rem-effects role=effects -->
## 效果与顺序

两个源都在写入 `RegDst` 之前读取，因此与任一源同名的目标使用执行前的值。余数发布后 `TPC` 推进 `4` 字节。

`REM` 不读内存，保留、描述符、数值标志、陷阱、指令束、特权、分支目标与控制流状态都保持不变。唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：有符号除法是对 `PTO_XLEN` 步的恢复除法循环，`REM` 不记录任何相关信息。不存在后续指令可以检查的除零粘滞标志。

<!-- PTO-READER-BLOCK: scalar-rem-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL`、`SrcR` 与 `RegDst` 编码都有定义，因此没有保留的选择子取值。固定编码位必须与规范 `32` 位载体匹配。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `REM` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：两种特殊的被除数/除数组合都有定义结果，因此 `REM` 没有由操作数选择的陷阱。它的故障边界仅是编码有效性与源可用性。

<!-- PTO-READER-BLOCK: scalar-rem-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `-7`、`a1` 为 `3` 时，`rem a0, a1, ->a2` 发布 `-1`，因为截断后的商是 `-2`，而 `-7 - (-2 * 3)` 等于 `-1`。

当 `a0` 为 `-7`、`a1` 为 `-3` 时，截断后的商是 `2`，因此 `a2` 同样收到 `-1`；余数跟随被除数的符号。当 `a1` 为 `0` 时，`a2` 收到 `-7` 本身。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | L32 | 32 | 0x00004057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| rem_32_0abbd6a3b865 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| rem_32_0abbd6a3b865 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| rem_32_0abbd6a3b865 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractOperation_REM() => ScalarOperation
begin
    return ScalarOperation_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractHandler_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSigned;
end;
pure func InstructionContractResult_REM(
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

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret both complete XLEN sources as signed two-complement integers and return dividend minus the quotient-truncated-toward-zero times divisor.
- A zero divisor returns the unchanged dividend. Signed minimum divided by negative one returns zero.
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

- rem a0, a1, ->a2
- rem t#1, zero, ->u
