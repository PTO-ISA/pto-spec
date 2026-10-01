<!-- GENERATED FROM: asl/scalar/alu/REMU.asl -->
# REMU

**Normative ASL source:** `asl/scalar/alu/REMU.asl`

REMU computes the unsigned XLEN remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remu-purpose role=purpose -->
## REMU 的作用

`REMU` 把两个完整的 `PTO_XLEN` 源当作无符号整数，并发布无符号余数。它有三个五位字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00005057`。该助记符不携带编码模式，因此操作数解释就是无符号解释。

由于取值是无符号的，源的纯位模式比较就能决定它是否大于除数；没有哪个符号位是特殊的。

<!-- PTO-READER-BLOCK: scalar-remu-mechanism role=mechanism -->
## 余数形成方式

分派路径调用 `ScalarRemainderUnsigned(left, right)`，两个源都通过 Reg5 映射读取（`asl/scalar/model/dispatch/alu.asl:240-245`）。零除数返回未改变的被除数；否则 `DivideWordUnsigned` 执行 `PTO_XLEN` 步恢复除法，辅助函数返回 `dividend - quotient * divisor`。

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

设计要点：恢复除法的比较基于 `UInt` 取值，因此第 `63` 位为 `1` 的被除数被视为大于 `2^63` 的值，而不是负数。被除数为 `0xFFFFFFFFFFFFFFFF`、除数为 `2` 时，`remu` 发布 `1`，而对相同位模式 `rem` 发布 `-1`。

设计要点：`DivideWordUnsigned` 只要运行余数达到除数就做一次减法，因此非零除数总是留下小于除数的余数，且永不为负。循环之后没有符号修正步骤，发布的字就是 `dividend - quotient * divisor` 的原始位模式。

<!-- PTO-READER-BLOCK: scalar-remu-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被除数，`SrcR` 是除数，`RegDst` 是余数的目标。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，任何读取都不消耗条目。
- `SrcR`，指令切片 `[20 +: 5]`：同样的五位映射；除数只用于比较与相减。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，并选择已定义的零除数答案，即未改变的被除数。

设计要点：零除数的答案是完整的被除数本身，它可以大到整个 `PTO_XLEN` 位模式。因此依赖“余数小于除数”的程序必须先排除零除数。

<!-- PTO-READER-BLOCK: scalar-remu-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此与 `SrcL` 或 `SrcR` 同名的目标对执行前的值做除法。余数发布后 `TPC` 推进 `4` 字节。

不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、分支目标与控制流状态都保持不变。仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：该指令只写入一个体系结构取值。恢复除法循环算出的商只是辅助函数的局部绑定，因此没有调用者能在不执行 `DIVU` 的情况下读到它。

<!-- PTO-READER-BLOCK: scalar-remu-constraints role=constraints -->
## 合法性与故障边界

Reg5 域中全部 `32` 个源编码与全部 `32` 个目标编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `REMU` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。所有检查都先于目标效果与 `TPC` 推进。

设计要点：无符号除法在整个操作数域上都是全定义的，零除数也不例外，因此 `REMU` 没有由操作数选择的陷阱。它的故障边界是编码有效性与源可用性。

<!-- PTO-READER-BLOCK: scalar-remu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `10`、`a1` 为 `4` 时，`remu a0, a1, ->a2` 发布 `2`。

当 `a0` 为 `0xFFFFFFFFFFFFFFFF`、`a1` 为 `2` 时，无符号余数是 `1`，因此 `a2` 收到 `1`。把 `a1` 设为 `0` 则发布完整的被除数 `0xFFFFFFFFFFFFFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | L32 | 32 | 0x00005057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remu_32_d7a5d1ebbbf5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remu_32_d7a5d1ebbbf5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remu_32_d7a5d1ebbbf5 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remu_32_d7a5d1ebbbf5 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remu_32_d7a5d1ebbbf5 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractOperation_REMU() => ScalarOperation
begin
    return ScalarOperation_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMU.asl -->
```asl
readonly func InstructionContractHandler_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsigned;
end;
pure func InstructionContractResult_REMU(
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

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret both complete XLEN sources as unsigned integers and return the unsigned remainder.
- A zero divisor returns the unchanged dividend.
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

- remu a0, a1, ->a2
- remu t#1, zero, ->u
