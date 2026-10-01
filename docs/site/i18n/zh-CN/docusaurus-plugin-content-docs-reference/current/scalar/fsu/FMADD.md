<!-- GENERATED FROM: asl/scalar/fsu/FMADD.asl -->
# FMADD

**Normative ASL source:** `asl/scalar/fsu/FMADD.asl`

FMADD computes one fused SrcL multiplied by SrcR plus SrcA operation through the active numeric profile.

## Normative identity {#PTO-INST-SCALAR-FMADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fmadd-purpose role=purpose -->
## FMADD 的作用

`FMADD` 求值一个形如 `product + addend` 的三操作数浮点表达式，并发布一个结果载体。`SrcL` 乘以 `SrcR`；第三个源 `SrcA` 是要与乘积相加或相减的加数。

整个表达式是一个融合操作：乘积绝不会先被舍入成自己的载体，然后再让加数参与。

<!-- PTO-READER-BLOCK: scalar-fmadd-mechanism role=mechanism -->
## 融合操作如何执行

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32，只使用每个源字的低 32 位，并零扩展到 XLEN。

契约指定 `FloatingFused_MADD`。处理程序读取 `SrcA`、`SrcL` 和 `SrcR`，把选定载体分别应用到每个源，然后向配置档请求一个结果和一个精确的 `NV`、`DZ`、`OF`、`UF`、`NX` 向量。在 `pto-v0` 参考配置档中，加数、左操作数和右操作数被转换为实数值，`left * right` 精确构成，乘积加加数由该精确乘积构成，最后的实数值用 `CORE_STATE[39:37]` 中编码的舍入模式编码一次。

特殊输入在有限值内核之前被回答。三个源中任意一个为 NaN 时发布规范 quiet NaN，并且只有当三者中至少有一个是 signaling NaN 时才记录 `NV`。`0` 乘以无穷发布规范 quiet NaN 并记录 `NV`。乘积无穷与有效符号相反的加数无穷也发布带 `NV` 的规范 quiet NaN；否则无穷乘积或无穷加数发布由有效符号选定的带符号无穷。

设计要点：对于 `FMSUB` 和 `FNMSUB`，加数符号会在符号分析中被取反；对于 `FNMADD` 和 `FNMSUB`，最终符号会在该分析之后取反。这正是让一条共享的特殊值规则覆盖全部四个助记符而不必为每个助记符单独写规则的原因。

<!-- PTO-READER-BLOCK: scalar-fmadd-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是左乘数选择器。
- `SrcR` 是右乘数选择器。
- `SrcA` 是加数选择器。
- `SrcType` 选择三个源共同使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-fmadd-effects role=effects -->
## 效果与顺序

三个源都在任何写入之前被读取，因此 `SrcL`、`SrcR`、`SrcA` 与 `RegDst` 可以指向同一个寄存器或队列槽，运算仍然使用指令执行前的值。压入 `T` 或 `U` 只在三次读取之后发生，因此对同一队列的「先读后压」看到的是原本就在那里的表项。

返回的五个标志位全部按位或进 `CORE_STATE[36:32]`，因此该运算可以置位粘滞标志，但绝不会清除标志。随后目的位置被写入或丢弃，之后 `TPC` 才前进 `4` 字节。不涉及内存访问，也不涉及保留状态。

<!-- PTO-READER-BLOCK: scalar-fmadd-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在任何源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不调用配置档、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

由于整个表达式是融合的，不存在中间载体，因此也不存在程序员可以观察或依赖的中间舍入步骤。保留的数值标志本身绝不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fmadd-example role=example -->
## 非规范示例

`fmadd.fd a0, a1, a2, ->a3` 把 `a0`、`a1` 和 `a2` 读作完整 FP64 载体，以一次舍入构成 `a0 * a1 + a2`，把返回的标志记录到 `CORE_STATE[36:32]`，并把结果写入 `a3`。

当 `SrcL` 保存 FP64 `2.0`、`SrcR` 保存 FP64 `3.0`、`SrcA` 保存 FP64 `1.0` 时，发布的值是 FP64 `7.0`，即 `2.0 * 3.0 + 1.0` 的精确结果。不产生内存流量，`TPC` 前进 `4` 字节。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmadd_32_c616a17bcb12 | L32 | 32 | 0x0000404b / 0x0000707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmadd_32_c616a17bcb12 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fmadd_32_c616a17bcb12 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fmadd_32_c616a17bcb12 | SrcA | 5 | 0–31 | none | none | fused addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmadd_32_c616a17bcb12 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmadd_32_c616a17bcb12 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmadd_32_c616a17bcb12 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fmadd_32_c616a17bcb12.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcA | fused addend Reg5 source |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractOperation_FMADD()
    => ScalarOperation
begin
    return ScalarOperation_FMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractHandler_FMADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;

pure func InstructionContractSourceTypeLegal_FMADD(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FMADD(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FMADD(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FMADD()
    => integer {1..3}
begin
    return 3;
end;

pure func InstructionContractUsesProfileFlags_FMADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FMADD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFusedOperation_FMADD()
    => FloatingFusedOperation
begin
    return FloatingFused_MADD;
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

- FMADD computes one fused SrcL multiplied by SrcR plus SrcA operation through the active numeric profile.
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

- fmadd.fd a0, a1, a2, ->a3
- fmadd.fs t#1, u#1, a0, ->t
