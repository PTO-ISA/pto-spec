<!-- GENERATED FROM: asl/scalar/fsu/FDIV.asl -->
# FDIV

**Normative ASL source:** `asl/scalar/fsu/FDIV.asl`

FDIV divides the left selected carrier by the right through the active numeric profile and publishes its sticky flags.

## Normative identity {#PTO-INST-SCALAR-FDIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-fdiv-purpose role=purpose -->
## FDIV 的作用

`FDIV` 用右侧选定的浮点载体除左侧选定的浮点载体，并把舍入后的商发布到 Reg5 目的。

它是二元 `FSU` 形式中的除法成员，因此与 `FADD`、`FMUL`、`FMIN`、`FMAX` 共享操作数形态和目的规则。

<!-- PTO-READER-BLOCK: scalar-fdiv-mechanism role=mechanism -->
## 商如何产生

`SrcType` 为两侧选择载体：编码 `00` 选择 FP64，编码 `01` 选择低字中的 FP32 载体。两个源先被规范化，随后用读取自 `core_state[39:37]` 的当前舍入模式执行二元除法。

除零是已定义结果而不是陷阱。有限非零被除数除以零除数产生无穷，其符号是两个操作数符号的异或，模型对该情形报告 `DZ`。零除以零以及无穷除以无穷产生静默 NaN 并报告 `NV`。

设计要点：由于零除数得到的是无穷而不是陷阱，程序可以在事后测试商是否为无穷；`DZ` 标志告诉它该无穷来自零除数，而不是来自有限除法溢出。

<!-- PTO-READER-BLOCK: scalar-fdiv-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 作为左侧 Reg5 源提供被除数。
- `SrcR` 作为右侧 Reg5 源提供除数。
- `SrcType` 为两侧选择源载体。
- `RegDst` 选择目的：编码 `1..23` 写所指的绝对 GPR，编码 `30` 压入 `U` 队列，编码 `31` 压入 `T` 队列，编码 `0` 以及编码 `24..29` 丢弃结果。

Reg5 源码读取绝对 GPR、`T#1..T#4` 或 `U#1..U#4`，且不消费队列项。源中的编码零读取架构零 GPR。

<!-- PTO-READER-BLOCK: scalar-fdiv-effects role=effects -->
## 效果与顺序

商被规范化到选定的载体宽度并写入一次，产生的标志按位或进粘性数值状态，`TPC` 前进 `4` 字节。内存、保留状态和描述符状态都不改变。

无穷操作数除以有限非零除数得到符号为异或结果的无穷，有限值除以无穷得到带符号零。两种情形都不报告任何标志，因为输入本身已经是无穷，没有产生新的异常条件。

<!-- PTO-READER-BLOCK: scalar-fdiv-constraints role=constraints -->
## 载体合法性与标志报告

`SrcType` 编码 `0` 和 `1` 已分配，编码 `2` 和 `3` 为保留值。载体检查在第一次架构源读取之前运行，因此保留的 `SrcType`、固定位不匹配或所选的 `T`、`U` 源不可用，都会在任何源、配置档、目的、标志、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。

每个 Reg5 目的编码都已分配。数值状态标志只更新粘性状态，永远不会引发同步 PTO 陷阱。

<!-- PTO-READER-BLOCK: scalar-fdiv-example role=example -->
## 非规范示例

This example illustrates the current owner and does not define arithmetic independently of the normative rule or active profile.

规范 FP64 示例是 `fdiv.fd a0, a1, ->a2`，其中 GPR `a0` 保存 `0x3ff0000000000000`，表示 `1.0`，GPR `a1` 保存 `0x4000000000000000`，表示 `2.0`：GPR `a2` 收到 `0x3fe0000000000000`，表示 `0.5`，并且不报告任何数值标志，因为商 `0.5` 在 FP64 中是精确的。

若改为用 `1.0` 除以 `0.0`，则产生无穷并置位 `DZ`；而商 `1.0 / 3.0` 并不精确，会报告 `NX`。每种情形下目的都会被写入。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
fdiv.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | L32 | 32 | 0x0000304b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fdiv_32_04a5bb6ab56f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fdiv_32_04a5bb6ab56f | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fdiv_32_04a5bb6ab56f | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fdiv_32_04a5bb6ab56f | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fdiv_32_04a5bb6ab56f | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fdiv_32_04a5bb6ab56f | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fdiv_32_04a5bb6ab56f.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractOperation_FDIV()
    => ScalarOperation
begin
    return ScalarOperation_FDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FDIV.asl -->
```asl
readonly func InstructionContractHandler_FDIV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;

pure func InstructionContractSourceTypeLegal_FDIV(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FDIV(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FDIV(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FDIV()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FDIV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FDIV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBinaryOperation_FDIV()
    => FloatingBinaryOperation
begin
    return FloatingBinary_DIV;
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

- FDIV divides the left selected carrier by the right through the active numeric profile and publishes its sticky flags.
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

- fdiv.fd a0, a1, ->a2
- fdiv.fs t#1, u#1, ->u
