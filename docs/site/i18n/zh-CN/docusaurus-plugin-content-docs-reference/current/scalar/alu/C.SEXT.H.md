<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.H.asl -->
# C.SEXT.H

**Normative ASL source:** `asl/scalar/alu/C.SEXT.H.asl`

C.SEXT.H sign-extends SrcL[15:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sext-h-purpose role=purpose -->
## C.SEXT.H 的作用

`C.SEXT.H` 取一个 Reg5 源的低半字，把它符号扩展到 `PTO_XLEN`，并把结果作为最新的临时值压入 `T`。

设计要点：`C.SEXT.H` 是压缩扩展族的半字成员。它的字段布局、固定的 `T` 目标和压入行为与 `C.SEXT.B` 完全相同；只有符号位从位 `7` 移到位置 `15`。

<!-- PTO-READER-BLOCK: scalar-c-sext-h-mechanism role=mechanism -->
## 结果形成方式

源的 `15..0` 位成为结果的 `15..0` 位，源位 `15` 被复制到从 `16` 往上的每一位。

设计要点：扩展只读取源一次并产生一个值。半字以上的位既不被检测也不被报告，因此一个在 16 位计算中溢出的值只是从位 `15` 重新扩展，没有标志也没有陷阱。

设计要点：压入会移动队列，因此新值成为 `T#1`，原 `T#1` 成为 `T#2`，原 `T#4` 被丢弃。

<!-- PTO-READER-BLOCK: scalar-c-sext-h-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：`c.sext.h t#1, ->t` 读取原 `T#1`，把半字扩展后的值压入为新 `T#1`，并把原件移到 `T#2`。临时源是被读取，而不是被消费。

设计要点：`SrcL` 的编码零读取架构零 GPR，其低半字为 `0`，因此 `c.sext.h zero, ->t` 压入 `0`。

<!-- PTO-READER-BLOCK: scalar-c-sext-h-effects role=effects -->
## 效果与顺序

源在压入之前读取，因此压入值由指令执行前的源计算得出。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-sext-h-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL` 编码都已分配，且固定编码位必须匹配规范形式，因此 `C.SEXT.H` 没有保留的操作数取值。

所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：半字扩展是全域定义的，因此 `C.SEXT.H` 没有依赖取值的故障。全部 `65536` 种可能的低半字都产生已定义结果，源的高 `48` 位被忽略而不是被检查。

<!-- PTO-READER-BLOCK: scalar-c-sext-h-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=65535` 时，低半字全为 1，因此 `c.sext.h a0, ->t` 压入 `18446744073709551615`。当 `a0=32767` 时符号位 `15` 为零，压入值为 `32767`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sext.h srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | C16 | 16 | 0x481c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sext_h_16_90cb7ea36bd3 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_H(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        16,
        TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- The compressed form has no destination field and always pushes exactly one result to T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Sign-extend source bit 15 through the XLEN result.
- Push the complete XLEN result to T. The source queue is non-consuming, and no explicit destination encoding exists.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization, movement, and extension are total fixed-width operations and raise no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- c.sext.h srcl, ->t
