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
## What JR does

`JR` transfers control to a register-based target plus a signed halfword displacement.

<!-- PTO-READER-BLOCK: scalar-jr-mechanism role=mechanism -->
## Mechanism

The scalar source is snapshotted, the signed immediate is shifted left by `1`, and the values are added to form the target.

The target must be even. An odd target raises `Fault_InstructionPC` without installing that target.

<!-- PTO-READER-BLOCK: scalar-jr-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left scalar source.

- `SrcZero` is the explicit zero-valued selector required by this encoding.

- `simm12` supplies a signed encoded immediate.

<!-- PTO-READER-BLOCK: scalar-jr-effects role=effects -->
## Effects and ordering

The accepted target replaces the control-flow PC as one architectural transition.

The jump has no scalar destination and does not access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-jr-constraints role=constraints -->
## Legality and fault order

Encoding and source availability are checked before target formation; target alignment is checked before the PC update.

<!-- PTO-READER-BLOCK: scalar-jr-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`jr SrcL, label` forms and validates the target described above before replacing the PC.
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
