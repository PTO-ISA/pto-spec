<!-- GENERATED FROM: asl/scalar/fsu/FEQS.asl -->
# FEQS

**Normative ASL source:** `asl/scalar/fsu/FEQS.asl`

FEQS performs ordered signaling equality and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FEQS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-feqs-purpose role=purpose -->
## FEQS 的作用

`FEQS` 测试两个选定的浮点载体是否相等，并把规范化的 `0` 或 `1` 写入 Reg5 目的；只要有 NaN 参与，就记录无效操作标志。

结尾的 `s` 后缀表示发信比较。结果值的计算与静默形式完全一致；不同的是该指令报告的标志。

<!-- PTO-READER-BLOCK: scalar-feqs-mechanism role=mechanism -->
## 报告 NaN 的有序相等

`SrcType` 为两侧选择载体，编码 `00` 表示 FP64，编码 `01` 表示低字中的 FP32 载体，每个源都先规范化到该载体。

任何 NaN 操作数都使比较返回假。此外，只要任一操作数是 NaN，该形式就记录 `NV`，而静默形式只在发信 NaN 时才记录 `NV`。有序情形仍由区分正负零的相等规则和固定的字序键给出。

设计要点：多出的这个标志是与 `FEQ` 的唯一区别。因此同一个比较存在两种合法编码，程序在希望意外出现的 NaN 不经单独测试就体现在粘性状态中时，选择发信的那一种。

<!-- PTO-READER-BLOCK: scalar-feqs-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧 Reg5 源。
- `SrcR` 提供右侧 Reg5 源。
- `SrcType` 为两侧选择源载体。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。源中的编码零读取架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-feqs-effects role=effects -->
## 效果与顺序

目的收到恰好 `1` 或 `0`，并规范化到完整 XLEN 字。任何被记录的 `NV` 都按位或进粘性数值状态，因此会一直保留到软件清除它，随后 `TPC` 前进 `4` 字节。

没有内存、保留状态或描述符效果，该指令也不产生其他数值状态标志。

<!-- PTO-READER-BLOCK: scalar-feqs-constraints role=constraints -->
## 载体合法性与发信形式行为

`SrcType` 编码 `0` 和 `1` 已分配，编码 `2` 和 `3` 为保留值。载体检查在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-feqs-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会脱离规范规则或活动配置档另行定义算术语义。

规范 FP64 示例是 `feqs.fd a0, a1, ->a2`，其中 GPR `a0` 保存 `0x3ff0000000000000`，GPR `a1` 保存 `0x3ff0000000000000`，都表示 `1.0`：GPR `a2` 收到 `1`，且不记录任何标志。

把 GPR `a1` 设为某个 NaN 编码，目的仍写入 `0`，而这次该指令会记录 `NV`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
feqs.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| feqs_32_1d3011890fa8 | L32 | 32 | 0x0800005b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| feqs_32_1d3011890fa8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| feqs_32_1d3011890fa8 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| feqs_32_1d3011890fa8 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| feqs_32_1d3011890fa8 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| feqs_32_1d3011890fa8 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| feqs_32_1d3011890fa8 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `feqs_32_1d3011890fa8.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractOperation_FEQS()
    => ScalarOperation
begin
    return ScalarOperation_FEQS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEQS.asl -->
```asl
readonly func InstructionContractHandler_FEQS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FEQS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FEQS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FEQS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FEQS()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FEQS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FEQS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FEQS()
    => FloatingCompareOperation
begin
    return FloatingCompare_EQ;
end;

pure func InstructionContractSignalingCompare_FEQS()
    => boolean
begin
    return TRUE;
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

- FEQS performs ordered signaling equality and returns canonical XLEN zero or one.
- Any NaN returns false. This signaling form records sticky NV for any NaN.
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

- feqs.fd a0, a1, ->a2
- feqs.fs t#1, u#1, ->u
