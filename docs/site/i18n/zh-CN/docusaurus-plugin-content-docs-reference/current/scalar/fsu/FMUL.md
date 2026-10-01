<!-- GENERATED FROM: asl/scalar/fsu/FMUL.asl -->
# FMUL

**Normative ASL source:** `asl/scalar/fsu/FMUL.asl`

FMUL multiplies two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FMUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fmul-purpose role=purpose -->
## FMUL 的作用

`FMUL` 相乘两个浮点标量并发布乘积。结果是 Reg5 目的位置中的浮点载体，因此它可以继续参与另一条标量浮点运算，也可以压入 `T` 或 `U` 队列供后续消费者使用。

<!-- PTO-READER-BLOCK: scalar-fmul-mechanism role=mechanism -->
## 算术如何执行

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32：只使用每个源字的低 32 位，并零扩展到 XLEN。

契约指定 `FloatingBinary_MUL`，因此声明的算术操作是 `left * right`。

选定的数值配置档同时返回结果以及精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。对于 `pto-v0` 参考配置档，有限的 FP32 和 FP64 载体被转换为实数值，用实数算术相乘，再用请求的舍入模式编码一次。舍入发生在末尾，因此发布的那个载体就是该运算唯一的舍入步骤。

设计要点：配置档返回标志而不是陷阱，指令再把这些标志按位或进粘滞状态。这就是为什么溢出的结果仍会作为无穷正常发布，而 `OF` 之后才在 `CORE_STATE[34]` 中可见。

<!-- PTO-READER-BLOCK: scalar-fmul-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是左源选择器。
- `SrcR` 是右源选择器。
- `SrcType` 选择两个源共同使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-fmul-effects role=effects -->
## 效果与顺序

两个源都在任何写入之前被读取，因此 `SrcL`、`SrcR` 与 `RegDst` 可以指向同一个寄存器或队列槽，运算仍然使用指令执行前的值。压入 `T` 或 `U` 只在两次读取之后发生，因此对同一队列的「先读后压」看到的是原本就在那里的表项。

返回的五个标志位全部按位或进 `CORE_STATE[36:32]`，因此该运算可以置位粘滞标志，但绝不会清除标志。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。不涉及内存访问，也不涉及保留状态。

<!-- PTO-READER-BLOCK: scalar-fmul-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在两个源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不调用配置档、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

当前舍入模式取自 `CORE_STATE[39:37]`；该指令没有逐指令的舍入字段。保留的数值标志本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fmul-example role=example -->
## 非规范示例

`fmul.fd a0, a1, ->a2` 把 `a0` 和 `a1` 读作完整 FP64 载体，相乘，记录配置档返回的标志，并把乘积写入 `a2`。不产生内存流量，`TPC` 前进 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fmul.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmul_32_7d521d9d65e7 | L32 | 32 | 0x0000204b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmul_32_7d521d9d65e7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmul_32_7d521d9d65e7 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fmul_32_7d521d9d65e7 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fmul_32_7d521d9d65e7 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmul_32_7d521d9d65e7 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmul_32_7d521d9d65e7 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fmul_32_7d521d9d65e7.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMUL.asl -->
```asl
readonly func InstructionContractOperation_FMUL()
    => ScalarOperation
begin
    return ScalarOperation_FMUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMUL.asl -->
```asl
readonly func InstructionContractHandler_FMUL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FMUL(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FMUL(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FMUL(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FMUL()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FMUL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FMUL()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FMUL()
    => FloatingBinaryOperation
begin
    return FloatingBinary_MUL;
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

- FMUL multiplies two selected FP64 or FP32 carriers through the active numeric profile and publishes its sticky flags.
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

- fmul.fd a0, a1, ->a2
- fmul.fs t#1, u#1, ->u
