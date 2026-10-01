<!-- GENERATED FROM: asl/scalar/fsu/FADD.asl -->
# FADD

**Normative ASL source:** `asl/scalar/fsu/FADD.asl`

FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fadd-purpose role=purpose -->
## FADD 的作用

`FADD` 把两个选定的浮点载体相加，并把舍入后的和发布到 Reg5 目的。

加法由当前数值配置档执行，因此和是配置档的舍入结果，而不是无界的实数值。

<!-- PTO-READER-BLOCK: scalar-fadd-mechanism role=mechanism -->
## 和如何产生

`SrcType` 选择载体：编码 `00` 选择 FP64，编码 `01` 选择每个源低字中的 FP32 载体。两个源都先规范化到该载体，然后模型用当前舍入模式（读取自 `core_state[39:37]`）计算二元加法。

特殊值规则在任何有限算术之前就决定结果。任一侧为 NaN 时结果为静默 NaN；两侧为异号无穷时结果为静默 NaN；恰好一侧为无穷时结果为带该符号的无穷。两个有限输入若其精确和超出目的格式范围，也会产生无穷，该溢出会记录 `OF` 与 `NX`。

设计要点：NaN 输入产生 NaN 结果，绝不会产生无穷，也不会产生有限数，因此这里检测到的 NaN 会在目的处保持可见，而不会被静默吸收。

<!-- PTO-READER-BLOCK: scalar-fadd-inputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧 Reg5 源。
- `SrcR` 提供右侧 Reg5 源。
- `SrcType` 为两侧选择源载体；整个操作只使用一个宽度。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。源中的编码零读取架构零 GPR，`RegDst` 中的编码零表示丢弃。

<!-- PTO-READER-BLOCK: scalar-fadd-effects role=effects -->
## 效果与顺序

结果被规范化到选定的载体宽度并写入一次，产生的标志按位或进粘性数值状态，随后 `TPC` 前进 `4` 字节。没有内存、保留状态或描述符效果。

配置档返回精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。模型把该向量按位或进已有粘性状态，因此先前指令置位的标志在本次未报告任何标志的 `FADD` 之后仍然保留。

<!-- PTO-READER-BLOCK: scalar-fadd-constraints role=constraints -->
## 载体合法性与粘性标志行为

`SrcType` 编码 `0` 和 `1` 已分配，编码 `2` 和 `3` 为保留值。载体检查在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配，因此没有非法的目的编码。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fadd-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会脱离规范规则或活动配置档另行定义算术语义。

规范 FP64 示例是 `fadd.fd a0, a1, ->a2`，其中 GPR `a0` 保存 `0x3ff0000000000000`，表示 `1.0`，GPR `a1` 保存 `0x3ff0000000000000`：GPR `a2` 收到 `0x4000000000000000`，表示 `2.0`。

由于两个操作数共用一个载体宽度，对 `T` 和 `U` 队列中的两个 FP32 值做 `FADD` 使用同一条指令，只是 `SrcType` 取 FP32 编码。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fadd.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fadd_32_b78b658e6740 | L32 | 32 | 0x0000004b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fadd_32_b78b658e6740 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fadd_32_b78b658e6740 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fadd_32_b78b658e6740 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fadd_32_b78b658e6740 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fadd_32_b78b658e6740 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fadd_32_b78b658e6740 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fadd_32_b78b658e6740.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractOperation_FADD()
    => ScalarOperation
begin
    return ScalarOperation_FADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FADD.asl -->
```asl
readonly func InstructionContractHandler_FADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FADD(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FADD(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FADD(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FADD()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FADD()
    => FloatingBinaryOperation
begin
    return FloatingBinary_ADD;
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

- FADD adds two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.
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

- fadd.fd a0, a1, ->a2
- fadd.fs t#1, u#1, ->u
