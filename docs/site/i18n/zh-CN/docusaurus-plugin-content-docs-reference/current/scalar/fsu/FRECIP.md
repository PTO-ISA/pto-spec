<!-- GENERATED FROM: asl/scalar/fsu/FRECIP.asl -->
# FRECIP

**Normative ASL source:** `asl/scalar/fsu/FRECIP.asl`

FRECIP applies the active numeric profile reciprocal operation to the selected FP64 or FP32 carrier.

## Normative identity {#PTO-INST-SCALAR-FRECIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-frecip-purpose role=purpose -->
## FRECIP 的作用

`FRECIP` 计算一个浮点标量的倒数并发布结果载体。它取单个源并产生单个目的位置。它应用数值配置档中的一个具名操作；它不是位操作指令，因此不会保留源的编码。

<!-- PTO-READER-BLOCK: scalar-frecip-mechanism role=mechanism -->
## 操作如何执行

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32，只使用源字的低 32 位，并零扩展到 XLEN。

契约指定 `FloatingUnary_RECIP`，配置档按 `1.0 / value` 求值。

选定的数值配置档同时返回结果以及精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。在 `pto-v0` 参考配置档中，该操作在实数值上求值，并用 `CORE_STATE[39:37]` 中编码的舍入模式编码一次。

零输入不做除法。它发布符号与输入相同的带符号无穷，并记录 `DZ`。无穷输入发布符号与输入相同的带符号零，且不记录标志。NaN 输入发布该载体的规范 quiet NaN；只有当输入是 signaling NaN 时才记录 `NV`。

设计要点：每个特殊输入都在进入有限值内核之前由显式架构规则回答。这就是为什么零输入仍会正常退休，并只留下粘滞 `DZ`，而不会引发陷阱。

<!-- PTO-READER-BLOCK: scalar-frecip-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是源选择器。没有第二个源字段。
- `SrcType` 选择读取源时使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-frecip-effects role=effects -->
## 效果与顺序

唯一的源在任何写入之前被读取，因此 `SrcL` 与 `RegDst` 可以指向同一个寄存器或队列槽，运算仍然使用指令执行前的值。压入 `T` 或 `U` 只在读取之后发生，因此对同一队列的「先读后压」看到的是原本就在那里的表项。

返回的五个标志位全部按位或进 `CORE_STATE[36:32]`，因此该运算可以置位粘滞标志，但绝不会清除标志。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。不涉及内存访问，也不涉及保留状态。

<!-- PTO-READER-BLOCK: scalar-frecip-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不调用配置档、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

当前舍入模式来自 `CORE_STATE[39:37]`；没有逐指令的舍入字段。已记录的标志本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-frecip-example role=example -->
## 非规范示例

`frecip.fd a0, ->a1` 把 `a0` 读作完整 FP64 载体，计算其倒数，记录返回的标志，并把结果写入 `a1`。

当 `a0` 保存 FP64 `-0.0` 时，指令把负无穷的 FP64 编码写入 `a1`，并在 `CORE_STATE[33]` 中置位粘滞 `DZ`。不产生内存流量，`TPC` 前进 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
frecip.{T} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| frecip_32_3d51f4f727ea | L32 | 32 | 0x0000207b / 0xf9f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| frecip_32_3d51f4f727ea | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| frecip_32_3d51f4f727ea | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| frecip_32_3d51f4f727ea | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| frecip_32_3d51f4f727ea | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| frecip_32_3d51f4f727ea | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| frecip_32_3d51f4f727ea | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `frecip_32_3d51f4f727ea.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractOperation_FRECIP()
    => ScalarOperation
begin
    return ScalarOperation_FRECIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FRECIP.asl -->
```asl
readonly func InstructionContractHandler_FRECIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;

pure func InstructionContractSourceTypeLegal_FRECIP(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FRECIP(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FRECIP(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FRECIP()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FRECIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FRECIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUnaryOperation_FRECIP()
    => FloatingUnaryOperation
begin
    return FloatingUnary_RECIP;
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

- FRECIP applies the active numeric profile reciprocal operation to the selected FP64 or FP32 carrier.
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

- frecip.fd a0, ->a1
- frecip.fs t#1, ->t
