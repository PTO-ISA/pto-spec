<!-- GENERATED FROM: asl/scalar/fsu/FCVTP.asl -->
# FCVTP

**Normative ASL source:** `asl/scalar/fsu/FCVTP.asl`

FCVTP converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-up mode.

## Normative identity {#PTO-INST-SCALAR-FCVTP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fcvtp-purpose role=purpose -->
## FCVTP 的作用

`FCVTP` 通过当前数值配置档使用固定向上舍入，把 FP64、FP32、FP16 或 E4M3 输入转换到原始 DstType 编码 `0..7`（UD/UW/UH/UB 或 SD/SW/SH/SB）。

<!-- PTO-READER-BLOCK: scalar-fcvtp-mechanism role=mechanism -->
## 数值机制

`SrcType=00`、`01`、`10` 和 `11` 分别选择 FP64、FP32、FP16 和 E4M3 载体。

当前配置档接收已经快照的操作数和助记符选定的操作，再返回结果以及精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。

`pto-v0` 参考配置档对所有共享类型组合使用与 `TCVT` 相同的确定性数值、舍入、范围、特殊值、饱和和标志规则；标量转换关闭饱和。

<!-- PTO-READER-BLOCK: scalar-fcvtp-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `DstType` 选择目的载体编码。

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `SrcL` 提供左侧标量源。

- `SrcType` 选择源载体宽度。

- Reg5 源选择器可以读取 GPR、T 或 U 状态，且不会消费临时队列项。

- 目的选择器可以写 GPR、压入 T/U，或只丢弃结果。

<!-- PTO-READER-BLOCK: scalar-fcvtp-effects role=effects -->
## 效果与顺序

所有显式源都会在数值状态或目的效果前完成快照。

配置档返回的五个标志全部按位或到粘滞数值状态；该操作不能清除已有标志。

结果完成发布或丢弃后，`TPC` 前进 `4` 字节。该指令不产生内存或保留状态效果。

<!-- PTO-READER-BLOCK: scalar-fcvtp-constraints role=constraints -->
## 类型与配置档边界

四个 `SrcType` 值均已分配。不可用 T/U 源会在读取源、调用配置档、更新标志或队列、写入目的以及改变 `TPC` 前引发 `Fault_IllegalInstruction`。

原始 DstType 编码 `0..7` 已分配；`8..31` 为保留值，并在产生效果前拒绝。

可移植指令契约拥有载体选择、源快照、标志累积、发布和故障顺序；当前具名配置档拥有数值结果和产生的标志。

<!-- PTO-READER-BLOCK: scalar-fcvtp-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不会脱离规范规则或当前配置档另行定义算术。

`fcvtp.fd2sd a0, ->a1` 选择载体，对源取快照，调用当前配置档，累积返回标志，发布结果，最后推进 `TPC`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvtp_32_84354a7aa6b1 | L32 | 32 | 0x0000406b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvtp_32_84354a7aa6b1 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvtp_32_84354a7aa6b1 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvtp_32_84354a7aa6b1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvtp_32_84354a7aa6b1 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fcvtp_32_84354a7aa6b1 | DstType | 5 | 0–7 | none | 8–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| fcvtp_32_84354a7aa6b1 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fcvtp_32_84354a7aa6b1 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fcvtp_32_84354a7aa6b1 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fcvtp_32_84354a7aa6b1.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTP.asl -->
```asl
readonly func InstructionContractOperation_FCVTP()
    => ScalarOperation
begin
    return ScalarOperation_FCVTP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTP.asl -->
```asl
readonly func InstructionContractHandler_FCVTP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTP(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_FCVTP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTP(encoded);
    return ScalarConvertFloatingTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTP(encoded: bits(5))
    => boolean
begin
    return ScalarFPToIntegerDestinationRawLegal(encoded);
end;

pure func InstructionContractDestinationCarrier_FCVTP(encoded: bits(5))
    => bits(5)
begin
    assert InstructionContractDestinationTypeLegal_FCVTP(encoded);
    return ScalarFPToIntegerDestinationTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FCVTP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTP()
    => NumericRoundingMode
begin
    return NumericRound_RTP;
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

- FCVTP converts an FP64, FP32, FP16, or E4M3 source to U64/U32/U16/U8 or S64/S32/S16/S8 with fixed round-up mode.
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

- fcvtp.fd2sd a0, ->a1
- fcvtp.fs2sw t#1, ->u
