<!-- GENERATED FROM: asl/scalar/bru/JR.asl -->
# JR

**Normative ASL source:** `asl/scalar/bru/JR.asl`

JR - Jump to the scalar-register target.

## Normative identity {#PTO-INST-SCALAR-JR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-jr-purpose role=purpose -->
## JR 的作用

`JR` 把控制流转移到寄存器基址加有符号半字位移形成的目标。

<!-- PTO-READER-BLOCK: scalar-jr-mechanism role=mechanism -->
## 执行机制

先对标量源取快照，再把有符号立即数左移 `1` 位，并将二者相加形成目标。

目标必须为偶数；奇数目标会引发 `Fault_InstructionPC`，且不会被写入 PC。

<!-- PTO-READER-BLOCK: scalar-jr-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧标量源。

- `SrcZero` 是该编码要求的显式零值选择器。

- `simm12` 提供有符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-jr-effects role=effects -->
## 效果与顺序

通过检查的目标会作为一次架构转换替换控制流 PC。

跳转没有标量目的位置，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-jr-constraints role=constraints -->
## 合法性与故障顺序

编码和源可用性会在形成目标前检查；目标对齐会在更新 PC 前检查。

<!-- PTO-READER-BLOCK: scalar-jr-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`jr SrcL, label` 先按上述规则形成并检查目标，再替换 PC。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
jr SrcL, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | L32 | 32 | 0x00006027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| jr_32_c4128e843b05 | SrcZero | 5 | 0–31 | none | none | explicit zero-valued source selector | Encoded zero selects value zero of the explicit zero-valued source selector. |
| jr_32_c4128e843b05 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcZero | explicit zero-valued source selector |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractOperation_JR() => ScalarOperation
begin
    return ScalarOperation_JR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractHandler_JR() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRegister;
end;

pure func InstructionContractRequiresEvenTarget_JR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_JR(
    register_value: Word,
    halfword_offset: Word)
    => Word
begin
    return register_value + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- JR - Jump to the scalar-register target.
- After decode and legality checks, execute the normative JumpRegister ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- jr SrcL, label
