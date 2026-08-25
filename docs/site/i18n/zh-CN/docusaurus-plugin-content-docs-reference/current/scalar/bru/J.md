<!-- GENERATED FROM: asl/scalar/bru/J.asl -->
# J

**Normative ASL source:** `asl/scalar/bru/J.asl`

J - Jump to the PC-relative target.

## Normative identity {#PTO-INST-SCALAR-J}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-j-purpose role=purpose -->
## J 的作用

`J` 把控制流转移到有符号 PC 相对半字目标。

<!-- PTO-READER-BLOCK: scalar-j-mechanism role=mechanism -->
## 执行机制

先对当前 PC 取快照，再把有符号位移左移 `1` 位，并将二者相加形成目标。

目标 PC 会被直接写入，之后不会再叠加普通顺序前进。

<!-- PTO-READER-BLOCK: scalar-j-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `simm22` 提供有符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-j-effects role=effects -->
## 效果与顺序

通过检查的目标会作为一次架构转换替换控制流 PC。

跳转没有标量目的位置，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-j-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-j-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`j label` 先按上述规则形成并检查目标，再替换 PC。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
j label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | L32 | 32 | 0x00000037 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| j_32_a303cf05af42 | simm22 | 22 | 0–4194303 | none | none | 22-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 22-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm22 | 22-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractOperation_J() => ScalarOperation
begin
    return ScalarOperation_J;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/J.asl -->
```asl
readonly func InstructionContractHandler_J() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRelative;
end;

pure func InstructionContractUsesCurrentPC_J()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_J(
    current_pc: Word,
    halfword_offset: Word)
    => Word
begin
    return current_pc + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- J - Jump to the PC-relative target.
- After decode and legality checks, execute the normative JumpRelative ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- j label
