<!-- GENERATED FROM: asl/scalar/fsu/FMAX.asl -->
# FMAX

**Normative ASL source:** `asl/scalar/fsu/FMAX.asl`

FMAX applies the architecture-owned ordered maximum, NaN, and signed-zero rules to selected FP64 or FP32 carriers.

## Normative identity {#PTO-INST-SCALAR-FMAX}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fmax-purpose role=purpose -->
## FMAX 的作用

`FMAX` 从两个浮点标量中选出一个并原样发布。它是架构自有的有序最大值：浮点 `fmax` 绝不陷阱，也绝不舍入；除两个操作数都是 NaN 的情况外，返回的是它收到的两个输入编码之一，而在两个操作数都是 NaN 时改为发布该载体的规范 quiet NaN。

由于胜出者是拷贝而不是重新计算，被选中的值不经过舍入，选择本身也不会产生不精确标志。

<!-- PTO-READER-BLOCK: scalar-fmax-mechanism role=mechanism -->
## 选择如何判定

`SrcType=00` 选择完整的 64 位 FP64 载体。`SrcType=01` 选择 FP32，只使用每个源字的低 32 位，并零扩展到 XLEN。

契约指定 `FloatingBinary_MAX`，并声明本形式既不使用配置档标志，也不使用当前舍入模式。因此处理程序完全不调用数值配置档；它调用架构自有的 NaN 与带符号零选择规则，并自行构造标志向量。

NaN 规则在设计上是不对称的：如果恰好一个操作数是 NaN，就返回另一个操作数，而且返回的是输入编码，绝不是新计算出的值。如果两个操作数都是 NaN，则改为返回所选载体的规范 quiet NaN。只有 signaling NaN 输入才置位粘滞 `NV`；quiet NaN 是静默的。

带符号零是显式排序的，而不是交给宿主：`+0` 与 `-0` 按值相等，因此最大值偏好 `+0`、最小值偏好 `-0`，而最大值遇到两个 `-0` 输入时仍保持 `-0`。对于两个非零操作数，排序使用与比较家族相同的编码序键，因此更大的值胜出。

设计要点：当另一个操作数是 NaN 时返回数值操作数，可以避免 NaN 悄悄吞掉有效值；拷贝胜出者而不是重新计算，可以保持载荷和零的符号不变。

<!-- PTO-READER-BLOCK: scalar-fmax-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择目的选择器：编码 `1`..`23` 写入 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 以及 `24`..`29` 丢弃结果。
- `SrcL` 是左源选择器。
- `SrcR` 是右源选择器。
- `SrcType` 选择两个源共同使用的载体。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，目的选择器 `0` 不写入任何内容。

<!-- PTO-READER-BLOCK: scalar-fmax-effects role=effects -->
## 效果与顺序

两个源都在任何写入之前被读取，因此 `SrcL`、`SrcR` 与 `RegDst` 可以指向同一个寄存器或队列槽，选择仍然使用指令执行前的值。压入 `T` 或 `U` 只在两次读取之后发生，因此对同一队列的「先读后压」看到的是原本就在那里的表项。

这里最多只会产生一个标志位：当某个输入是 signaling NaN 时产生 `NV`。它以按位或的方式写入 `CORE_STATE[36:32]`，因此先前的标志绝不会被清除。被选中的值被写入或丢弃，之后 `TPC` 才前进 `4` 字节。不涉及内存访问，也不涉及保留状态。

<!-- PTO-READER-BLOCK: scalar-fmax-constraints role=constraints -->
## 保留类型与拒绝

`SrcType=10` 和 `SrcType=11` 是保留值。处理程序在两个源寄存器第一次被读取之前检查载体类型，因此保留类型会引发 `Fault_IllegalInstruction`，且不读取源、不置标志、不改变队列、不写目的位置、不推进 `TPC`。

指名不可用 `T` 或 `U` 槽的源选择器在同一位置以同样方式被拒绝。

由于本形式从不查询配置档，当前舍入模式无法改变它的结果，它也不可能产生 `DZ`、`OF`、`UF` 或 `NX` 位。

<!-- PTO-READER-BLOCK: scalar-fmax-example role=example -->
## 非规范示例

`fmax.fs a0, a1, ->a2` 把 `a0` 和 `a1` 的低 32 位读作 FP32 载体，并把选中的编码写入 `a2`。

当 `a0` 保存 FP32 `-0.0`、`a1` 保存 FP32 `+0.0` 时，两者按值相等；`FMAX` 返回 `+0.0`，且不记录任何标志。当 `a0` 保存 signaling NaN、`a1` 保存 FP32 `3.0` 时，指令写入 FP32 编码的 `3.0`，并置位粘滞 `NV`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fmax.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmax_32_eaf3880d7739 | L32 | 32 | 0x0000605b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmax_32_eaf3880d7739 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmax_32_eaf3880d7739 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fmax_32_eaf3880d7739 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fmax_32_eaf3880d7739 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmax_32_eaf3880d7739 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fmax_32_eaf3880d7739 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fmax_32_eaf3880d7739.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractOperation_FMAX()
    => ScalarOperation
begin
    return ScalarOperation_FMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMAX.asl -->
```asl
readonly func InstructionContractHandler_FMAX()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FMAX(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FMAX(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FMAX(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FMAX()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FMAX()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FMAX()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractBinaryOperation_FMAX()
    => FloatingBinaryOperation
begin
    return FloatingBinary_MAX;
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

- FMAX applies the architecture-owned ordered maximum, NaN, and signed-zero rules to selected FP64 or FP32 carriers.
- One NaN returns the numeric input; two NaNs return the canonical quiet NaN; a signaling NaN records sticky NV; signed-zero ordering is architecture-owned.
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

- fmax.fd a0, a1, ->a2
- fmax.fs t#1, u#1, ->u
