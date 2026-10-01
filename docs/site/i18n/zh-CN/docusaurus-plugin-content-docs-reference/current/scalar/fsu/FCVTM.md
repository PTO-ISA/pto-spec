<!-- GENERATED FROM: asl/scalar/fsu/FCVTM.asl -->
# FCVTM

**Normative ASL source:** `asl/scalar/fsu/FCVTM.asl`

FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.

## Normative identity {#PTO-INST-SCALAR-FCVTM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fcvtm-purpose role=purpose -->
## FCVTM 的作用

`FCVTM` 把浮点载体转换为整数载体，并按向负无穷舍入规则把结果写入 Reg5 目的。

舍入规则由助记符固定，不从寄存器字段读取，因此需要该舍入方式的程序可以直接指名它。

<!-- PTO-READER-BLOCK: scalar-fcvtm-mechanism role=mechanism -->
## 把有限源舍入到整数目的

`SrcType` 选择源载体，编码 `0..3` 全部已分配，依次表示 FP64、FP32、FP16 和 E4M3。`DstType` 是原始五位字段：原始编码 `0..3` 选择无符号目的 `UD`、`UW`、`UH`、`UB`，原始编码 `4..7` 选择对应的有符号目的 `SD`、`SW`、`SH`、`SB`，原始编码 `8..31` 为保留值。

源在配置档运行之前规范化到完整字。结果把已有限的值舍入到整数目的，因此舍入决策只发生一次：在小数部分被丢弃的时候。始终向下舍入，因此 `2.5` 变为 `2`，`-2.5` 变为 `-3`。

设计要点：由于该规则是契约的固定部分，同一源值对本助记符总是产生同一整数，与当前舍入模式字段无关；需要不同平局规则的两个程序只需指名不同助记符。

<!-- PTO-READER-BLOCK: scalar-fcvtm-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供唯一的 Reg5 源。
- `SrcType` 选择源载体；编码 `0..3` 全部已分配。
- `DstType` 选择目的整数宽度与符号性；编码 `0..7` 已分配，编码 `8..31` 为保留值。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。`SrcL` 中的编码零读取架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-fcvtm-effects role=effects -->
## 效果与顺序

整数结果被规范化到选定的目的宽度并写入一次，配置档返回的标志按位或进粘性数值状态。随后 `TPC` 前进 `4` 字节。内存、保留状态和描述符状态都不改变。

NaN 源为目的发布零，无穷源发布目的端点值，两种情形都记录 `NV` 而不是引发陷阱。该助记符不会对结果做饱和处理；标量转换中饱和是关闭的。

<!-- PTO-READER-BLOCK: scalar-fcvtm-constraints role=constraints -->
## 类型合法性与舍入字段

类型合法性在第一次架构源读取之前确定：每个 `SrcType` 都合法，且 `DstType` 必须至多为 `7`。保留的目的类型、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配，因此没有非法的目的编码。该助记符不查询当前舍入字段，因此改变该字段不会改变本条指令的结果。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fcvtm-example role=example -->
## 非规范示例

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

规范示例是 `fcvtm.fd2sd a0, ->a1`：GPR `a0` 保存 `0x4004000000000000`，表示 `2.5`，而编码 `DstType` 选择 `SD` 的形式会把 `2` 写入目的。

配套示例 `fcvtm.fs2sw t#1, ->u` 把 `T#1` 项低字中的 FP32 载体转换为有符号 32 位整数，并把结果压入 `U` 队列。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fcvtm.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvtm_32_8801f1562870 | L32 | 32 | 0x0000206b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvtm_32_8801f1562870 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvtm_32_8801f1562870 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fcvtm_32_8801f1562870 | DstType | 5 | 0–7 | none | 8–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| fcvtm_32_8801f1562870 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fcvtm_32_8801f1562870 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fcvtm_32_8801f1562870 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fcvtm_32_8801f1562870.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTM.asl -->
```asl
readonly func InstructionContractOperation_FCVTM()
    => ScalarOperation
begin
    return ScalarOperation_FCVTM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTM.asl -->
```asl
readonly func InstructionContractHandler_FCVTM()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTM(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_FCVTM(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTM(encoded);
    return ScalarConvertFloatingTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTM(encoded: bits(5))
    => boolean
begin
    return ScalarFPToIntegerDestinationRawLegal(encoded);
end;

pure func InstructionContractDestinationCarrier_FCVTM(encoded: bits(5))
    => bits(5)
begin
    assert InstructionContractDestinationTypeLegal_FCVTM(encoded);
    return ScalarFPToIntegerDestinationTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FCVTM()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTM()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTM()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTM()
    => NumericRoundingMode
begin
    return NumericRound_RTM;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select FP64, FP32, FP16, and E4M3; every code is assigned.
- DstType raw codes 0..3 select UD/UW/UH/UB, raw codes 4..7 select SD/SW/SH/SB, and raw codes 8..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select FP64, FP32, FP16, and E4M3.
- DstType raw codes 0 through 3 map to unsigned 64-, 32-, 16-, and 8-bit results; raw codes 4 through 7 map to the corresponding signed results; raw codes 8 through 31 are reserved.

## State effects

- FCVTM converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-down mode.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- The pto-v0 reference profile uses the same deterministic conversion rule and flags as TCVT for every shared scalar type pair; scalar conversion supplies saturation disabled.
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

- fcvtm.fd2sd a0, ->a1
- fcvtm.fs2sw t#1, ->u
