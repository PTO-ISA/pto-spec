<!-- GENERATED FROM: asl/scalar/fsu/FABS.asl -->
# FABS

**Normative ASL source:** `asl/scalar/fsu/FABS.asl`

FABS clears the sign bit of the selected FP64 or FP32 carrier, preserves every other carrier bit, and publishes no numeric flags.

## Normative identity {#PTO-INST-SCALAR-FABS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fabs-purpose role=purpose -->
## FABS 的作用

`FABS` 清除选定浮点载体的符号位，并把得到的字作为普通目的值发布。它是对载体的位操作，而不是带舍入的算术运算。

该指令是 `FSU` 家族的一元形式：一个 Reg5 源、一个 Reg5 目的或丢弃，并且没有提交或谓词效果。

<!-- PTO-READER-BLOCK: scalar-fabs-mechanism role=mechanism -->
## 符号如何被清除

`SrcType` 选择载体。编码 `00` 选择完整 FP64 载体，模型因此用 `0x7fffffffffffffff` 对读到的字做掩码。编码 `01` 选择低字中的 FP32 载体，因此用 `0x7fffffff` 对低 `32` 位做掩码并把结果零扩展。

只有符号位被改变。指数位和有效数位，包括 NaN 载荷或无穷指数，都原样复制，该指令本身也不发布任何数值标志。

设计要点：由于该变换从不检查值类别，`FABS` 既不能把发信 NaN 变成静默 NaN，也不能引发无效操作标志。需要该行为的程序必须改用算术运算。

<!-- PTO-READER-BLOCK: scalar-fabs-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供唯一的 Reg5 源。
- `SrcType` 选择源载体宽度。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，都不消费队列项。`SrcL` 中的编码零读取架构零 GPR，`RegDst` 中的编码零表示丢弃。

<!-- PTO-READER-BLOCK: scalar-fabs-effects role=effects -->
## 效果与顺序

目的被写入一次，内容是按选定宽度规范化的掩码后载体，随后 `TPC` 前进 `4` 字节。该指令没有内存、保留状态或描述符效果。

已有数值状态标志保持不变。由于 `FABS` 只清除选定载体的符号位，FP64 结果与源最多只差这一位；而 FP32 结果的高 `32` 位会被置零，因为选定载体是零扩展后的低字。

<!-- PTO-READER-BLOCK: scalar-fabs-constraints role=constraints -->
## 保留类型编码与故障顺序

`SrcType` 编码 `0` 和 `1` 已分配；编码 `2` 和 `3` 为保留值。编码合法性在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配，因此没有非法的目的编码，该指令也没有可能报告数值异常的配置档钩子。数值状态更新永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fabs-example role=example -->
## 非规范示例

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

对 FP64 形式，规范示例是 `fabs.fd a0, ->a1`：GPR `a0` 保存 `0xc000000000000000`，表示 `-2.0`，GPR `a1` 收到 `0x4000000000000000`，表示 `2.0`，其余各位完全相同。

对 FP32 形式，规范示例是 `fabs.fs t#1, ->t`：`T#1` 项的低字用 `0x7fffffff` 做掩码并零扩展，结果压入 `T` 队列。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fabs.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fabs_32_9515e008bf17 | L32 | 32 | 0x0000007b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fabs_32_9515e008bf17 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fabs_32_9515e008bf17 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fabs_32_9515e008bf17 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fabs_32_9515e008bf17 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fabs_32_9515e008bf17 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fabs_32_9515e008bf17 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fabs_32_9515e008bf17.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractOperation_FABS()
    => ScalarOperation
begin
    return ScalarOperation_FABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FABS.asl -->
```asl
readonly func InstructionContractHandler_FABS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FABS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FABS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FABS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FABS()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FABS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FABS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUnaryOperation_FABS()
    => FloatingUnaryOperation
begin
    return FloatingUnary_ABS;
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

- FABS clears the sign bit of the selected FP64 or FP32 carrier, preserves every other carrier bit, and publishes no numeric flags.
- Existing NV, DZ, OF, UF, and NX state is unchanged.
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

- fabs.fd a0, ->a1
- fabs.fs t#1, ->t
