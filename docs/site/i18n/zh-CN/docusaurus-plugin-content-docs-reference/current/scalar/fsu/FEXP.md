<!-- GENERATED FROM: asl/scalar/fsu/FEXP.asl -->
# FEXP

**Normative ASL source:** `asl/scalar/fsu/FEXP.asl`

FEXP applies the active numeric profile exponential operation to the selected FP64 or FP32 carrier.

## Normative identity {#PTO-INST-SCALAR-FEXP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fexp-purpose role=purpose -->
## FEXP 的作用

`FEXP` 对选定的浮点载体施加指数运算，并把舍入后的结果写入 Reg5 目的。

它是一元算术形式，因此读取一个源、查询数值配置档，并可能引发配置档为其他浮点运算报告的相同异常标志。

<!-- PTO-READER-BLOCK: scalar-fexp-mechanism role=mechanism -->
## 指数如何计算

`SrcType` 选择载体，编码 `00` 表示 FP64，编码 `01` 表示低字中的 FP32 载体，源在运算运行之前规范化到该载体。

该运算通过配置档求值，使用来自 `core_state[39:37]` 的当前舍入模式。特殊值规则在任何有限求值之前决定三种情形：NaN 输入产生静默 NaN，且仅当输入为发信 NaN 时记录 `NV`；正无穷输入产生正无穷且不记录标志；负无穷输入产生正零且不记录标志。

设计要点：助记符命名的是运算而不是算法。可移植模型通过其参考配置档求值指数，因此实现绑定的是已发布的结果与标志，而不是某种特定的求值顺序。

<!-- PTO-READER-BLOCK: scalar-fexp-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供唯一的 Reg5 源。
- `SrcType` 选择源载体。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。`SrcL` 中的编码零读取架构零 GPR，`RegDst` 中的编码零表示丢弃。

<!-- PTO-READER-BLOCK: scalar-fexp-effects role=effects -->
## 效果与顺序

结果被规范化到选定的载体宽度并写入一次，配置档返回的标志按位或进粘性数值状态，`TPC` 前进 `4` 字节。没有内存、保留状态或描述符效果。

由于标志是按位或而不是赋值，先前运算记录的标志在未报告任何内容的 `FEXP` 之后仍然可见。

<!-- PTO-READER-BLOCK: scalar-fexp-constraints role=constraints -->
## 载体合法性与标志报告

`SrcType` 编码 `0` 和 `1` 已分配，编码 `2` 和 `3` 为保留值。载体检查在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fexp-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会脱离规范规则或活动配置档另行定义算术语义。

规范 FP64 示例是 `fexp.fd a0, ->a1`：GPR `a0` 保存 `0x0000000000000000`，表示 `0.0`，GPR `a1` 收到 `0x3ff0000000000000`，表示 `1.0`，且不记录任何标志。

配套示例 `fexp.fs t#1, ->t` 对 `T#1` 项低字中的 FP32 载体施加同样的运算，并把结果压入 `T` 队列。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fexp.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | L32 | 32 | 0x0000307b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexp_32_592ef5288c7d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexp_32_592ef5288c7d | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexp_32_592ef5288c7d | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fexp_32_592ef5288c7d | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fexp_32_592ef5288c7d | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fexp_32_592ef5288c7d.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractOperation_FEXP()
    => ScalarOperation
begin
    return ScalarOperation_FEXP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEXP.asl -->
```asl
readonly func InstructionContractHandler_FEXP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FEXP(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FEXP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FEXP(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FEXP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FEXP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FEXP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUnaryOperation_FEXP()
    => FloatingUnaryOperation
begin
    return FloatingUnary_EXP;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.

## State effects

- FEXP applies the active numeric profile exponential operation to the selected FP64 or FP32 carrier.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- For pto-v0 finite FP32 and FP64 carriers, execute the declared operation through the reference finite floating profile using the selected rounding mode and publish the returned NV, DZ, OF, UF, and NX flags.
- Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.
- Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Validate every encoded type before the first architectural source read or profile call.
- Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.
- Accumulate produced flags, publish or discard the destination, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.
- Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap.

## Examples

- fexp.fd a0, ->a1
- fexp.fs t#1, ->t
