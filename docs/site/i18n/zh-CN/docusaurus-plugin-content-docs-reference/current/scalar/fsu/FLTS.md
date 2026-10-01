<!-- GENERATED FROM: asl/scalar/fsu/FLTS.asl -->
# FLTS

**Normative ASL source:** `asl/scalar/fsu/FLTS.asl`

FLTS performs ordered signaling less-than comparison and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FLTS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-flts-purpose role=purpose -->
## FLTS 的作用

`FLTS` 比较两个浮点标量并写出整数判定结果。它是有序的 signaling 小于比较：当左操作数严格小于右操作数时，目的位置得到规范 XLEN `1`；其他一切情况（包括任何 NaN 情况）得到规范 XLEN `0`。

这个整数结果就是 Reg5 目的位置中的普通字，因此用于判定的比较可以直接驱动后续整数控制流，无需任何转换步骤。

<!-- PTO-READER-BLOCK: scalar-flts-mechanism role=mechanism -->
## 比较如何判定

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32，只使用每个源字的低 32 位，并零扩展到 XLEN。

指令契约指定 `FloatingCompare_LT`，并声明自己是一次 signaling 比较。处理程序先询问任一操作数是否为 NaN。如果是，答案立即为 `0`；因为本形式属于 signaling，所以这里会置位粘滞的 `NV`；比较本身绝不会针对 NaN 求值。

对于非 NaN 操作数，模型比较的是编码序键而不是原始位模式，因此 `-0` 与 `+0` 被视为相等，负数排在正数之下。这里只需要严格序测试，所以 `less` 直接决定结果。

设计要点：对「任一操作数为 NaN」的检测是使有序规则成为全函数的守卫。它保证任何 NaN 都不可能满足小于关系，因此发布的值始终是规范的 `0` 或 `1`，绝不会是依赖 NaN 的编码。

<!-- PTO-READER-BLOCK: scalar-flts-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是左源选择器。
- `SrcR` 是右源选择器。
- `SrcType` 选择两个源共同使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-flts-effects role=effects -->
## 效果与顺序

两次源读取都在任何写入之前完成，因此 `SrcL`、`SrcR` 与 `RegDst` 可以指向同一个寄存器或队列槽，比较仍然看到指令执行前的值。压入 `T` 或 `U` 只在两次读取之后发生，因此同一条指令中既读取又被压入的选择器看到的是原本就在那里的表项。

粘滞 `NV` 更新以按位或的方式写入 `CORE_STATE[36:32]`，因此先前的标志绝不会被清除。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。该指令不进行内存访问，也不留下保留状态。

<!-- PTO-READER-BLOCK: scalar-flts-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在两个源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

数值标志只是状态。已记录的 `NV` 本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-flts-example role=example -->
## 非规范示例

`flts.fs a0, a1, ->u` 把 `a0` 和 `a1` 的低 32 位读作 FP32 值，并把判定结果压入 `U` 队列。

当 `a0` 保存 FP32 `1.0`、`a1` 保存 FP32 `2.0` 时，有序测试成立，压入 `1`。当 `a0` 保存一个 quiet NaN 时，测试返回 `0`，`CORE_STATE[32]` 中置位 `NV`，`TPC` 仍然前进 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
flts.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| flts_32_c744c874e6a2 | L32 | 32 | 0x0800205b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| flts_32_c744c874e6a2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| flts_32_c744c874e6a2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| flts_32_c744c874e6a2 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| flts_32_c744c874e6a2 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| flts_32_c744c874e6a2 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| flts_32_c744c874e6a2 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| flts_32_c744c874e6a2 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| flts_32_c744c874e6a2 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `flts_32_c744c874e6a2.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FLTS.asl -->
```asl
readonly func InstructionContractOperation_FLTS()
    => ScalarOperation
begin
    return ScalarOperation_FLTS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FLTS.asl -->
```asl
readonly func InstructionContractHandler_FLTS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FLTS(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FLTS(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FLTS(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FLTS()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FLTS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FLTS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FLTS()
    => FloatingCompareOperation
begin
    return FloatingCompare_LT;
end;

pure func InstructionContractSignalingCompare_FLTS()
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

- FLTS performs ordered signaling less-than comparison and returns canonical XLEN zero or one.
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

- flts.fd a0, a1, ->a2
- flts.fs t#1, u#1, ->u
