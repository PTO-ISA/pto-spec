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

`FADD` 通过当前数值配置档对两个选定的 FP64 或 FP32 载体求和，发布配置档返回的结果，并把返回的 5 位状态向量累积到粘滞数值状态。

<!-- PTO-READER-BLOCK: scalar-fadd-mechanism role=mechanism -->
## 配置档介导的机制

`SrcType=00` 选择完整 FP64 载体，`SrcType=01` 从零扩展后的低 32 位选择 FP32 载体。指令使用当前舍入模式调用配置档的二元加法操作。

选定的配置档返回结果以及 `NV`、`DZ`、`OF`、`UF`、`NX`；`FADD` 把这些位按位或到已有的粘滞 `CORE_STATE[36:32]` 字段中。

在 `pto-v0` 参考配置档中，加法是确定性的原始载体模运算，并返回全零标志。该参考行为并不是 IEEE-754 或目标硬件一致性声明。

<!-- PTO-READER-BLOCK: scalar-fadd-inputs role=inputs-outputs -->
## 输入与目的位置

- `SrcL` 和 `SrcR` 接受全部 Reg5 源选择器，包括不消费的 T/U 源。
- `RegDst` 的 `1..23` 写入 GPR，`30` 压入 U，`31` 压入 T，`0` 和 `24..29` 只丢弃结果。

页面显示的所有操作数字段都有编码。编码零是一个值：源选择器 `0` 读取零 GPR，目的 `0` 丢弃结果，`SrcType=00` 选择 FP64。

<!-- PTO-READER-BLOCK: scalar-fadd-effects role=effects -->
## 效果与顺序

第一次读取源或调用配置档之前，会先检查类型合法性。随后两个源都在标志累积或目的发布前完成快照。

产生的标志会按位或到粘滞数值状态，结果随后被发布或丢弃，`TPC` 再前进 `4` 字节。数值标志本身不会引发同步 PTO 陷阱。

`FADD` 不产生内存或保留状态效果。

<!-- PTO-READER-BLOCK: scalar-fadd-constraints role=constraints -->
## 类型与配置档边界

`SrcType=10` 和 `SrcType=11` 为保留值，会在读取源、调用配置档、写入目的、更新标志、压入队列或改变 `TPC` 之前引发 `Fault_IllegalInstruction`。选中的 T/U 源尚不可用时，适用相同的效果前故障边界。

可移植契约拥有载体选择、源快照、标志累积、目的发布和拒绝顺序。当前具名数值配置档拥有算术结果和产生的状态向量。

<!-- PTO-READER-BLOCK: scalar-fadd-example role=example -->
## 非规范使用示例

下面的示例只说明选择和发布，并不脱离当前配置档另行定义浮点算术。

`fadd.fd a0, a1, ->a2` 选择 FP64 载体路径，对两个源取快照，使用当前舍入模式调用配置档加法，累积返回的标志，把返回载体写入 `a2`，最后让 `TPC` 前进 `4` 字节。
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
