<!-- GENERATED FROM: asl/scalar/fsu/FNE.asl -->
# FNE

**Normative ASL source:** `asl/scalar/fsu/FNE.asl`

FNE performs ordered quiet inequality and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FNE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fne-purpose role=purpose -->
## FNE 的作用

`FNE` 执行有序不相等比较（静默 NaN 形式），并发布规范化 XLEN 一或零。

<!-- PTO-READER-BLOCK: scalar-fne-mechanism role=mechanism -->
## 数值机制

`SrcType=00` 选择完整 FP64 载体；`SrcType=01` 选择零扩展后的低 32 位 FP32 载体。

任一输入为 NaN 时，有序比较结果为假。

静默 NaN 形式只对信号 NaN 记录粘滞 `NV`。

<!-- PTO-READER-BLOCK: scalar-fne-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `SrcL` 提供左侧标量源。

- `SrcR` 提供右侧标量源。

- `SrcType` 选择源载体宽度。

- Reg5 源选择器可以读取 GPR、T 或 U 状态，且不会消费临时队列项。

- 目的选择器可以写 GPR、压入 T/U，或只丢弃结果。

<!-- PTO-READER-BLOCK: scalar-fne-effects role=effects -->
## 效果与顺序

所有显式源都会在数值状态或目的效果前完成快照。

架构产生的 `NV` 会在目的发布前按位或到粘滞数值状态。

结果完成发布或丢弃后，`TPC` 前进 `4` 字节。该指令不产生内存或保留状态效果。

<!-- PTO-READER-BLOCK: scalar-fne-constraints role=constraints -->
## 类型与配置档边界

`SrcType=10` 和 `SrcType=11` 为保留值。保留类型或不可用 T/U 源会在读取源、调用配置档、更新标志或队列、写入目的以及改变 `TPC` 前引发 `Fault_IllegalInstruction`。

数值标志更新本身不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fne-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不会脱离规范规则或当前配置档另行定义算术。

`fne.fd a0, a1, ->a2` 应用架构定义的特殊值规则，在推进 `TPC` 前发布规范化输出。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fne.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fne_32_822c18caca3b | L32 | 32 | 0x0000105b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fne_32_822c18caca3b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fne_32_822c18caca3b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fne_32_822c18caca3b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fne_32_822c18caca3b | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fne_32_822c18caca3b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fne_32_822c18caca3b | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fne_32_822c18caca3b | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fne_32_822c18caca3b | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fne_32_822c18caca3b.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNE.asl -->
```asl
readonly func InstructionContractOperation_FNE()
    => ScalarOperation
begin
    return ScalarOperation_FNE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNE.asl -->
```asl
readonly func InstructionContractHandler_FNE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FNE(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FNE(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FNE(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FNE()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FNE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FNE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FNE()
    => FloatingCompareOperation
begin
    return FloatingCompare_NE;
end;

pure func InstructionContractSignalingCompare_FNE()
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

- FNE performs ordered quiet inequality and returns canonical XLEN zero or one.
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

- fne.fd a0, a1, ->a2
- fne.fs t#1, u#1, ->u
