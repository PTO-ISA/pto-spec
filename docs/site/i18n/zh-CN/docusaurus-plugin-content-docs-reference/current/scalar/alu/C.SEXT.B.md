<!-- GENERATED FROM: asl/scalar/alu/C.SEXT.B.asl -->
# C.SEXT.B

**Normative ASL source:** `asl/scalar/alu/C.SEXT.B.asl`

C.SEXT.B sign-extends SrcL[7:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SEXT-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sext-b-purpose role=purpose -->
## C.SEXT.B 的作用

`C.SEXT.B` 取一个 Reg5 源的低字节，把它符号扩展到 `PTO_XLEN`，并把结果作为最新的临时值压入 `T`。

设计要点：压缩扩展形式没有目标字段，因此每次成功执行恰好产生一个 `T` 项。字节、半字和字三种变体只在符号位的位置上不同，这就是三个助记符共用同一机制的原因。

<!-- PTO-READER-BLOCK: scalar-c-sext-b-mechanism role=mechanism -->
## 结果形成方式

源的 `7..0` 位成为结果的 `7..0` 位，源位 `7` 被复制到从 `8` 往上的每一位。

设计要点：符号位由助记符而不是由字段选择，因此这里无法请求零扩展。需要无符号字节的程序要使用该族中做零扩展的成员，或用 `ANDI` 屏蔽该值。

设计要点：压入会移动整个队列而不是覆盖某个槽位，因此新值成为 `T#1`，原 `T#4` 被丢弃。

<!-- PTO-READER-BLOCK: scalar-c-sext-b-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。
- 目标固定为 `T`：每次成功执行恰好压入一个 XLEN 结果。

设计要点：临时源合法，因此 `c.sext.b t#1, ->t` 对原 `T#1` 做符号扩展并压入结果，同时旧值移到 `T#2`。源队列只被读取，永远不会被弹出。

设计要点：`SrcL` 的编码零读取架构零 GPR，其低字节为 `0`，因此 `c.sext.b zero, ->t` 压入 `0`。

<!-- PTO-READER-BLOCK: scalar-c-sext-b-effects role=effects -->
## 效果与顺序

源在压入之前读取，因此该指令观察不到它即将产生的值。

压入之后，`TPC` 前进 `2` 字节。GPR、`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-sext-b-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL` 编码都已分配，且固定编码位必须匹配规范形式，因此 `C.SEXT.B` 没有保留的操作数取值。

所选 `T` 或 `U` 源不可用会在压入之前、`TPC` 前进之前以及任何其他效果之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：扩展是全域定义的，因此 `C.SEXT.B` 从不因源取值而触发故障。`256` 种可能的低字节每一种都产生已定义的 XLEN 结果。

<!-- PTO-READER-BLOCK: scalar-c-sext-b-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=255` 时，低字节为 `255`，其符号位被置起，`c.sext.b a0, ->t` 压入 `18446744073709551615`。当 `a0=127` 时，符号位为零，压入值为 `127`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sext.b srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sext_b_16_8ffd07d15409 | C16 | 16 | 0x401c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sext_b_16_8ffd07d15409 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sext_b_16_8ffd07d15409 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_SEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_SEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_SEXT_B(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        8,
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

- Sign-extend source bit 7 through the XLEN result.
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

- c.sext.b srcl, ->t
