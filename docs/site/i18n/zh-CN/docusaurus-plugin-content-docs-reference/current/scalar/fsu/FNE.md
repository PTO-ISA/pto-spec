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

`FNE` 比较两个浮点标量并写出整数判定结果。它是有序的 quiet 不等比较：当两个操作数不同时，目的位置得到规范 XLEN `1`；当两者相等或任一为 NaN 时，得到规范 XLEN `0`。

这个整数结果就是 Reg5 目的位置中的普通字，因此用于判定的比较可以直接驱动后续整数控制流，无需任何转换步骤。

<!-- PTO-READER-BLOCK: scalar-fne-mechanism role=mechanism -->
## 比较如何判定

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32，只使用每个源字的低 32 位，并零扩展到 XLEN。

指令契约指定 `FloatingCompare_NE`，并声明自己是一次 quiet 比较。只有当输入是 signaling NaN 时，处理程序才记录 `NV`，因为 quiet 比较不能仅仅因为比较了 quiet NaN 就置位无效标志。

相等性按值而不是按原始编码判定：`-0` 与 `+0` 的编码不同，但按值相等，因此该组合发布的判定结果是 `0`。这里只需要不等测试，所以结果就是相等测试的取反。

设计要点：当 NaN 是预期的数据值而不是错误时，应当使用 quiet 形式。它仍然回答 `0`，但不改动 `CORE_STATE[32]`，因此之后检查粘滞标志时不会被一次普通的 NaN 比较污染。signaling NaN 仍会被报告，所以真正的无效无法隐藏。

<!-- PTO-READER-BLOCK: scalar-fne-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是左源选择器。
- `SrcR` 是右源选择器。
- `SrcType` 选择两个源共同使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-fne-effects role=effects -->
## 效果与顺序

两次源读取都在任何写入之前完成，因此 `SrcL`、`SrcR` 与 `RegDst` 可以指向同一个寄存器或队列槽，比较仍然看到指令执行前的值。压入 `T` 或 `U` 只在两次读取之后发生，因此同一条指令中既读取又被压入的选择器看到的是原本就在那里的表项。

粘滞标志更新以按位或的方式写入 `CORE_STATE[36:32]`，因此先前的标志绝不会被清除。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。该指令不进行内存访问，也不留下保留状态。

<!-- PTO-READER-BLOCK: scalar-fne-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在两个源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

本形式不使用当前舍入模式，因为比较两个载体并不是舍入操作。数值标志只是状态：已记录的 `NV` 本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fne-example role=example -->
## 非规范示例

`fne.fd a0, a1, ->a2` 把 `a0` 和 `a1` 读作完整 FP64 载体，并把判定结果写入 `a2`。

当 `a0` 保存 FP64 `+0.0`、`a1` 保存 FP64 `-0.0` 时，两者按值相等，因此写入 `0`，且不记录任何标志。当 `a0` 保存 quiet NaN、`a1` 保存 FP64 `1.0` 时，写入 `0`，并且不记录任何标志，因为本形式属于 quiet 且该 NaN 是 quiet 的。
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
