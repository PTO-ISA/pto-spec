<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.H.asl -->
# C.ZEXT.H

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.H.asl`

C.ZEXT.H zero-extends SrcL[15:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-H}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-h-purpose role=purpose -->
## C.ZEXT.H 的作用

`C.ZEXT.H` 取一个 Reg5 源的低 16 位，把位 `15` 以上的每一位结果位填零，并把 XLEN 结果压入 `T`。

设计要点：这个形式与 `C.ZEXT.B` 调用同一个处理器，只是宽度参数不同，而两者的编码只在固定位上不同。因此把所选宽度从字节改为半字改变的是操作码，而不是宽度字段或目标字段。

<!-- PTO-READER-BLOCK: scalar-c-zext-h-mechanism role=mechanism -->
## 结果形成方式

共享扩展辅助函数取 `value[15:0]` 并零扩展到 `PTO_XLEN`。无论源被丢弃的高位是什么，发布值总在 `0..65535` 之内。

设计要点：截断发生在扩展之前，因此辅助函数从不查看位 `15` 以上的位。位 `15` 为 1 的源不会被视为负数；发布的是所选 16 位的无符号读数。

<!-- PTO-READER-BLOCK: scalar-c-zext-h-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是唯一被编码的操作数：Reg5 源，编码 `0..23`、`24..27` 和 `28..31` 分别选择 GPR、`T#1..T#4` 和 `U#1..U#4`，且不消费队列项。
- 压缩编码把目标固定为 `T`。

设计要点：`SrcL` 的编码零读取架构零 GPR，因此对 `zero` 做半字扩展会压入 `0`；这条指令除了通过寄存器，没有办法读取常数。

<!-- PTO-READER-BLOCK: scalar-c-zext-h-effects role=effects -->
## 效果与顺序

所选源在目标效果之前快照，且源不被消费。压入把队列向更旧的索引方向移动，因此结果成为 `T#1`，原 `T#4` 被丢弃。

压入之后，`TPC` 前进 `2` 字节。不会写任何 GPR，`U` 项、内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-c-zext-h-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL` 编码都已分配，固定编码位必须匹配规范形式；没有需要限定范围的立即数。扩展是全域定义的，不会引发算术异常。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。无法译码的 16 位形式在 `PC` 处引发 `Fault_IllegalInstruction`，不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：由于所选宽度由操作码固定，操作数检查拒绝这条指令的唯一理由就是队列源不可用。没有任何源位型会让扩展变得无法译码或产生异常。

<!-- PTO-READER-BLOCK: scalar-c-zext-h-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `0x12345678` 时，`c.zext.h a0, ->t` 压入 `0x5678`，即 `22136`。当 `u#1` 保存全 1 值时，`c.zext.h u#1, ->t` 压入 `65535`，并让 `u#1` 仍可在索引 `0` 处读取。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.h srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_h_16_4c0976791cbc | C16 | 16 | 0x601c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_h_16_4c0976791cbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_h_16_4c0976791cbc | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_H;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.H.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_H(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        16,
        FALSE);
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

- Zero-fill every result bit above source bit 15.
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

- c.zext.h srcl, ->t
