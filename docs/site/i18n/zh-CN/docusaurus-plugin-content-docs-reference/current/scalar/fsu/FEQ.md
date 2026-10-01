<!-- GENERATED FROM: asl/scalar/fsu/FEQ.asl -->
# FEQ

**Normative ASL source:** `asl/scalar/fsu/FEQ.asl`

FEQ performs ordered quiet equality and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FEQ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-feq-purpose role=purpose -->
## FEQ 的作用

`FEQ` 测试两个选定的浮点载体是否相等，并把规范化的 `0` 或 `1` 写入 Reg5 目的。

它是比较组中的静默相等成员，因此无序输入产生确定的假结果，而不是异常。

<!-- PTO-READER-BLOCK: scalar-feq-mechanism role=mechanism -->
## 对 NaN 给出假结果的有序相等

`SrcType` 为两侧选择载体：编码 `00` 选择 FP64，编码 `01` 选择低字中的 FP32 载体。每个源在任何测试之前都先规范化到该载体。

只要任一规范化后的操作数是 NaN，比较就返回假，无论另一个操作数是什么。否则模型用“正零与负零是同一值的相等编码”这一规则比较载体，并从固定的字序键推导有序情形，而不是依赖某个数值库。

设计要点：这里任何 NaN（静默或发信）都比较为假，但静默形式只在输入含发信 NaN 时记录无效操作标志。因此静默 NaN 经过 `FEQ` 时不改变粘性状态，这正是该助记符与发信形式 `FEQS` 的区别。

<!-- PTO-READER-BLOCK: scalar-feq-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧 Reg5 源。
- `SrcR` 提供右侧 Reg5 源。
- `SrcType` 为两侧选择源载体。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。源中的编码零读取架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-feq-effects role=effects -->
## 效果与顺序

比较成立时目的收到恰好 `1`，不成立时收到恰好 `0`，并规范化到完整 XLEN 字。若记录了标志，则按位或进粘性数值状态，随后 `TPC` 前进 `4` 字节。

该指令没有内存、保留状态或描述符效果。除非本条指令自己记录标志，否则已有的 `NV`、`DZ`、`OF`、`UF`、`NX` 状态保持不变。

<!-- PTO-READER-BLOCK: scalar-feq-constraints role=constraints -->
## 载体合法性与静默形式行为

`SrcType` 编码 `0` 和 `1` 已分配，编码 `2` 和 `3` 为保留值。载体检查在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-feq-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会脱离规范规则或活动配置档另行定义算术语义。

规范 FP64 示例是 `feq.fd a0, a1, ->a2`，其中 GPR `a0` 保存 `0x3ff0000000000000`，GPR `a1` 保存 `0x3ff0000000000000`，都表示 `1.0`：GPR `a2` 收到 `1`。

把 GPR `a1` 设为 `0xbff0000000000000`（表示 `-1.0`）会写入 `0`；把 GPR `a1` 设为静默 NaN 编码（如 `0x7ff8000000000000`）也会写入 `0`，且粘性状态保持不变。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
feq.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| feq_32_9435d6959c3c | L32 | 32 | 0x0000005b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| feq_32_9435d6959c3c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| feq_32_9435d6959c3c | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| feq_32_9435d6959c3c | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| feq_32_9435d6959c3c | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| feq_32_9435d6959c3c | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `feq_32_9435d6959c3c.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEQ.asl -->
```asl
readonly func InstructionContractOperation_FEQ()
    => ScalarOperation
begin
    return ScalarOperation_FEQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEQ.asl -->
```asl
readonly func InstructionContractHandler_FEQ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FEQ(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FEQ(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FEQ(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FEQ()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FEQ()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FEQ()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FEQ()
    => FloatingCompareOperation
begin
    return FloatingCompare_EQ;
end;

pure func InstructionContractSignalingCompare_FEQ()
    => boolean
begin
    return FALSE;
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

- FEQ performs ordered quiet equality and returns canonical XLEN zero or one.
- Any NaN returns false. This quiet form records sticky NV only for a signaling NaN.
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

- feq.fd a0, a1, ->a2
- feq.fs t#1, u#1, ->u
