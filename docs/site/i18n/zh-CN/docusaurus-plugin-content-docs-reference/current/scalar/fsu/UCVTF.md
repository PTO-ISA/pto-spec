<!-- GENERATED FROM: asl/scalar/fsu/UCVTF.asl -->
# UCVTF

**Normative ASL source:** `asl/scalar/fsu/UCVTF.asl`

UCVTF converts a U64, U32, U16, or U8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.

## Normative identity {#PTO-INST-SCALAR-UCVTF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ucvtf-purpose role=purpose -->
## UCVTF 的作用

`UCVTF` 把一个标量无符号整数转换为浮点载体并发布该载体。它是标量的整数到浮点方向；浮点到整数方向由另外的转换助记符拥有。

<!-- PTO-READER-BLOCK: scalar-ucvtf-mechanism role=mechanism -->
## 转换如何执行

`SrcType` 选择源整数载体：编码 `0` 选择 64 位类型，`1` 选择 32 位类型，`2` 选择 16 位类型，`3` 选择 8 位类型，在这里即 U64、U32、U16 和 U8。源载体使用零扩展，因此窄源按其表示的无符号值读取。

`DstType` 选择目的浮点载体：编码 `0` 选择 FP64，`1` 选择 FP32，`2` 选择 FP16，`3` 选择 E4M3。编码 `4` 到 `31` 为保留值。

转换走的是 tile 转换家族所用的同一条标量与 tile 共享转换参考实现，并且关闭饱和。舍入模式是 `CORE_STATE[39:37]` 中编码的那个，配置档返回结果以及精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。

转换并不限于精确值。当整数幅值无法在目的载体中精确表示时，目的载体在当前舍入模式下取最接近的可表示值，并记录不精确标志 `NX`；当它超出范围时，结果是符号匹配的无穷，并记录 `OF`；但 `E4M3` 目的载体例外，它没有无穷编码，改为发布其规范 quiet NaN。

设计要点：目的载体由编码字段选择，而不是由目的寄存器决定，因此同一个源值可以在不改变任何寄存器角色的情况下转换为 FP64、FP32、FP16 或 E4M3。标量转换关闭饱和，因此溢出的值绝不会被钳制到最大有限值。

<!-- PTO-READER-BLOCK: scalar-ucvtf-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是源选择器。没有第二个源字段。
- `SrcType` 选择源整数载体。
- `DstType` 选择目的浮点载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。
- 发布的字是目的编码零扩展到 XLEN 的结果，因此高于所选载体宽度的那些高位为零。

<!-- PTO-READER-BLOCK: scalar-ucvtf-effects role=effects -->
## 效果与顺序

源在两个编码类型都通过校验之后才被读取，而且它在任何写入之前被读取。因此 `SrcL` 与 `RegDst` 可以指向同一个寄存器或队列槽，转换仍然使用指令执行前的值。压入 `T` 或 `U` 只在读取之后发生。

返回的标志按位或进 `CORE_STATE[36:32]`，因此转换可以置位粘滞标志，但绝不会清除标志。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。不涉及内存访问，也不涉及保留状态。

<!-- PTO-READER-BLOCK: scalar-ucvtf-constraints role=constraints -->
## 保留类型与拒绝

四个 `SrcType` 编码全部分配，因此本助记符没有保留的源类型。`DstType` 编码 `4` 到 `31` 为保留值。处理程序在源寄存器第一次被读取之前解析两个类型编码，因此保留的 `DstType` 会引发 `Fault_IllegalInstruction`，且不读取源、不调用配置档、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

已记录的数值标志本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-ucvtf-example role=example -->
## 非规范示例

`ucvtf.ud2fd a0, ->a1` 把 `a0` 读作 U64 源，并把同一数值的 FP64 编码写入 `a1`。

当 `a0` 保存 U64 值 `2` 时，发布的 FP64 值为 `2.0`，且 `NX` 保持清零，因为该值精确。当 `a0` 保存 U64 最大值且 `DstType` 选择 FP32 时，该幅值无法精确表示，因此发布的值是最接近的 FP32 值并记录 `NX`；由于该幅值仍远低于 FP32 范围，`OF` 保持清零。溢出需要很窄的目的载体：当 `DstType` 选择 E4M3 时，幅值超过 `448` 就会溢出。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ucvtf_32_987f4e019c32 | L32 | 32 | 0x0000706b / 0x01f0707f | [{"field":"DstType","operator":"one-of","values":[0,1,2,3]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ucvtf_32_987f4e019c32 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ucvtf_32_987f4e019c32 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ucvtf_32_987f4e019c32 | DstType | 5 | 0–3 | none | 4–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| ucvtf_32_987f4e019c32 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| ucvtf_32_987f4e019c32 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| ucvtf_32_987f4e019c32 | SrcType | 2 | 0–3 | none | none | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `ucvtf_32_987f4e019c32.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractOperation_UCVTF()
    => ScalarOperation
begin
    return ScalarOperation_UCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/UCVTF.asl -->
```asl
readonly func InstructionContractHandler_UCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_UCVTF(encoded: bits(2))
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSourceCarrier_UCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_UCVTF(encoded);
    return ScalarUnsignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_UCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 3;
end;

pure func InstructionContractSourceArity_UCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_UCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_UCVTF()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType codes 0..3 select U64, U32, U16, and U8 with zero extension.
- DstType codes 0..3 select FP64, FP32, FP16, and E4M3; codes 4..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- Every SrcType code is assigned: 0, 1, 2, and 3 select U64, U32, U16, and U8.
- DstType codes 0 through 3 select FP64, FP32, FP16, and E4M3; codes 4 through 31 are reserved.

## State effects

- UCVTF converts a U64, U32, U16, or U8 source to FP64, FP32, FP16, or E4M3 through the common scalar/TCVT profile.
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

- ucvtf.ud2fd a0, ->a1
- ucvtf.uw2fs t#1, ->u
