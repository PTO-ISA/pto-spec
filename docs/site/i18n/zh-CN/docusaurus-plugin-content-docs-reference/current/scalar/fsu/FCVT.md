<!-- GENERATED FROM: asl/scalar/fsu/FCVT.asl -->
# FCVT

**Normative ASL source:** `asl/scalar/fsu/FCVT.asl`

FCVT converts an FP64, FP32, FP16, or E4M3 source to any of those four floating destinations through the common scalar/TCVT profile.

## Normative identity {#PTO-INST-SCALAR-FCVT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fcvt-purpose role=purpose -->
## FCVT 的作用

`FCVT` 把一个选定的浮点载体转换为另一个浮点载体，并把结果写入 Reg5 目的。两侧都留在浮点域内，因此不适用整数舍入规则。

类型由两个编码字段选择，因此一个助记符覆盖四种受支持浮点格式的全部组合。

<!-- PTO-READER-BLOCK: scalar-fcvt-mechanism role=mechanism -->
## 转换如何计算

`SrcType` 选择源载体，`DstType` 选择目的载体。编码 `0`、`1`、`2`、`3` 在两侧都表示 FP64、FP32、FP16 和 E4M3，因此每个源码都已分配，而目的编码 `4` 到 `31` 为保留值。

源值在配置档运行之前规范化到完整字，结果再规范化到目的宽度。因此加宽窄源采用零扩展，而不是重新解释相邻位。

转换使用当前舍入模式进行，模型从 `core_state[39:37]` 读取它，并返回精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量，该向量按位或进粘性数值状态。

设计要点：舍入模式来自寄存器字段而不是由助记符固定，因此需要特定平局规则的程序只需写入一次该规则，该区域内的每条 `FCVT` 都会遵守它。

<!-- PTO-READER-BLOCK: scalar-fcvt-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供唯一的 Reg5 源。
- `SrcType` 选择源载体；编码 `0..3` 全部已分配。
- `DstType` 选择目的载体；编码 `0..3` 已分配，编码 `4..31` 为保留值。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。`SrcL` 中的编码零读取架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-fcvt-effects role=effects -->
## 效果与顺序

转换后的载体写入一次，并按目的宽度规范化，随后 `TPC` 前进 `4` 字节。内存、保留状态和描述符状态都不改变。

NaN 源会发布目的格式的规范 NaN。目的格式存在无穷时，无穷源发布无穷；目的格式没有无穷时（例如目的为 E4M3），结果是该格式的规范 NaN，并记录 `OF` 与 `NX`。该指令不写谓词或指令束状态，发布结果的是目的写入而不是配置档调用。

<!-- PTO-READER-BLOCK: scalar-fcvt-constraints role=constraints -->
## 已分配的源码与保留的目的编码

类型合法性在第一次架构源读取之前确定：这里每个 `SrcType` 都合法，而大于 `3` 的 `DstType` 为保留值。保留的目的类型、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配，因此没有非法的目的编码。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fcvt-example role=example -->
## 非规范示例

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

规范的加宽示例是 `fcvt.fd2fs a0, ->a1`：GPR `a0` 保存 `0x3ff0000000000000`，表示 FP64 的 `1.0`，GPR `a1` 收到 `0x3f800000`，即 `1.0` 的 FP32 编码位于低字并零扩展。

配套示例 `fcvt.fs2fd t#1, ->u` 把 `T#1` 项低字中的 FP32 载体加宽为 FP64，并把结果压入 `U` 队列。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fcvt.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvt_32_1102f5aeeda9 | L32 | 32 | 0x0000006b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvt_32_1102f5aeeda9 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvt_32_1102f5aeeda9 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fcvt_32_1102f5aeeda9 | DstType | 5 | 0–3 | none | 4–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| fcvt_32_1102f5aeeda9 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fcvt_32_1102f5aeeda9 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fcvt_32_1102f5aeeda9 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fcvt_32_1102f5aeeda9.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVT.asl -->
```asl
readonly func InstructionContractOperation_FCVT()
    => ScalarOperation
begin
    return ScalarOperation_FCVT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVT.asl -->
```asl
readonly func InstructionContractHandler_FCVT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVT(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_FCVT(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVT(encoded);
    return ScalarConvertFloatingTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVT(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 3;
end;

pure func InstructionContractSourceArity_FCVT()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select FP64, FP32, FP16, and E4M3; every code is assigned.
- DstType codes 0..3 select FP64, FP32, FP16, and E4M3; codes 4..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select FP64, FP32, FP16, and E4M3.
- DstType codes 0 through 3 select FP64, FP32, FP16, and E4M3; codes 4 through 31 are reserved.

## State effects

- FCVT converts an FP64, FP32, FP16, or E4M3 source to any of those four floating destinations through the common scalar/TCVT profile.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- The pto-v0 reference profile uses the same deterministic conversion rule and flags as TCVT for every shared scalar type pair; scalar conversion supplies saturation disabled.
- Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
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

- fcvt.fd2fs a0, ->a1
- fcvt.fs2fd t#1, ->u
