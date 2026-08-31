<!-- GENERATED FROM: asl/scalar/fsu/FNMSUB.asl -->
# FNMSUB

**Normative ASL source:** `asl/scalar/fsu/FNMSUB.asl`

FNMSUB computes the negation of one fused SrcL multiplied by SrcR minus SrcA operation through the active numeric profile.

## Normative identity {#PTO-INST-SCALAR-FNMSUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fnmsub-purpose role=purpose -->
## FNMSUB 的作用

`FNMSUB` 通过当前数值配置档对融合的左乘右再减加数结果取负。

<!-- PTO-READER-BLOCK: scalar-fnmsub-mechanism role=mechanism -->
## 数值机制

`SrcType=00` 选择完整 FP64 载体；`SrcType=01` 选择零扩展后的低 32 位 FP32 载体。

当前配置档接收已经快照的操作数和助记符选定的操作，再返回结果以及精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。

在 `pto-v0` 参考配置档中，载体乘积与加数相减后按选定宽度取模取负。该确定性参考规则不是 IEEE-754 或目标硬件声明。

<!-- PTO-READER-BLOCK: scalar-fnmsub-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `SrcA` 提供加数源。

- `SrcL` 提供左侧标量源。

- `SrcR` 提供右侧标量源。

- `SrcType` 选择源载体宽度。

- Reg5 源选择器可以读取 GPR、T 或 U 状态，且不会消费临时队列项。

- 目的选择器可以写 GPR、压入 T/U，或只丢弃结果。

<!-- PTO-READER-BLOCK: scalar-fnmsub-effects role=effects -->
## 效果与顺序

所有显式源都会在数值状态或目的效果前完成快照。

配置档返回的五个标志全部按位或到粘滞数值状态；该操作不能清除已有标志。

结果完成发布或丢弃后，`TPC` 前进 `4` 字节。该指令不产生内存或保留状态效果。

<!-- PTO-READER-BLOCK: scalar-fnmsub-constraints role=constraints -->
## 类型与配置档边界

`SrcType=10` 和 `SrcType=11` 为保留值。保留类型或不可用 T/U 源会在读取源、调用配置档、更新标志或队列、写入目的以及改变 `TPC` 前引发 `Fault_IllegalInstruction`。

可移植指令契约拥有载体选择、源快照、标志累积、发布和故障顺序；当前具名配置档拥有数值结果和产生的标志。

<!-- PTO-READER-BLOCK: scalar-fnmsub-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不会脱离规范规则或当前配置档另行定义算术。

`fnmsub.fd a0, a1, a2, ->a3` 选择载体，对源取快照，调用当前配置档，累积返回标志，发布结果，最后推进 `TPC`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fnmsub.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | L32 | 32 | 0x0000704b / 0x0000707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnmsub_32_6542d56665b3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnmsub_32_6542d56665b3 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fnmsub_32_6542d56665b3 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fnmsub_32_6542d56665b3 | SrcA | 5 | 0–31 | none | none | fused addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fnmsub_32_6542d56665b3 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fnmsub_32_6542d56665b3.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcA | fused addend Reg5 source |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractOperation_FNMSUB()
    => ScalarOperation
begin
    return ScalarOperation_FNMSUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMSUB.asl -->
```asl
readonly func InstructionContractHandler_FNMSUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;

pure func InstructionContractSourceTypeLegal_FNMSUB(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FNMSUB(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FNMSUB(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FNMSUB()
    => integer {1..3}
begin
    return 3;
end;

pure func InstructionContractUsesProfileFlags_FNMSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FNMSUB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFusedOperation_FNMSUB()
    => FloatingFusedOperation
begin
    return FloatingFused_NMSUB;
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

- FNMSUB computes the negation of one fused SrcL multiplied by SrcR minus SrcA operation through the active numeric profile.
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

- fnmsub.fd a0, a1, a2, ->a3
- fnmsub.fs t#1, u#1, a0, ->t
