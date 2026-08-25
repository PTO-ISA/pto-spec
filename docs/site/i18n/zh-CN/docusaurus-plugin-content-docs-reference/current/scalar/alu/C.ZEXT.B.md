<!-- GENERATED FROM: asl/scalar/alu/C.ZEXT.B.asl -->
# C.ZEXT.B

**Normative ASL source:** `asl/scalar/alu/C.ZEXT.B.asl`

C.ZEXT.B zero-extends SrcL[7:0] to XLEN and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-ZEXT-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-zext-b-purpose role=purpose -->
## C.ZEXT.B 的作用

`C.ZEXT.B` 是一条 16 位标量 ALU 指令。它把源值低 8 位零扩展到 XLEN；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后把源值低 8 位零扩展到 XLEN，最后才产生目标效果。

- 操作专属的宽度、有符号性和立即数规则由助记符以及下方编码字段共同确定。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 5 位字段，通过 Reg5 选择标量输入。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-effects role=effects -->
## 效果与顺序

所有标量源都在发布前完成快照；指令完成时恰好向 T 推入一个结果。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 2 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-constraints role=constraints -->
## 合法性与故障边界

物化、移动或扩展按固定位宽获得总定义，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在状态效果前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-c-zext-b-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `C.ZEXT.B` 示例说明：源值低 8 位 `0x80` 零扩展后得到正 XLEN 值 `128`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.zext.b srcL, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | C16 | 16 | 0x581c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_zext_b_16_7ea1a59fa2da | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractOperation_C_ZEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.ZEXT.B.asl -->
```asl
readonly func InstructionContractHandler_C_ZEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;

pure func InstructionContractResult_C_ZEXT_B(value: Word)
    => Word
begin
    return ExtendScalarValue(
        value,
        8,
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

- Zero-fill every result bit above source bit 7.
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

- c.zext.b srcl, ->t
