<!-- GENERATED FROM: asl/scalar/bru/HL.SETRET.asl -->
# HL.SETRET

**Normative ASL source:** `asl/scalar/bru/HL.SETRET.asl`

HL.SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-HL-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setret-purpose role=purpose -->
## What HL.SETRET does

`HL.SETRET` computes and records the architectural return address relative to the current `TPC`.

<!-- PTO-READER-BLOCK: scalar-hl-setret-mechanism role=mechanism -->
## Mechanism

The unsigned `32`-bit immediate is zero-extended, shifted left by `1`, and added to the snapshotted current `TPC`.

The same target is written to GPR `R10` and bundle-local return-address state; execution does not branch to that target.

<!-- PTO-READER-BLOCK: scalar-hl-setret-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `imm32` supplies the encoded immediate or displacement.

<!-- PTO-READER-BLOCK: scalar-hl-setret-effects role=effects -->
## Effects and ordering

The return target is published before the normal successful `TPC` advance of `6` bytes.

No memory, reservation, numeric-status, or predicate state changes.

<!-- PTO-READER-BLOCK: scalar-hl-setret-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-hl-setret-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`hl.setret imm, ->Ra` records the return target without transferring control to it.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setret imm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | HL48 | 48 | 0x00000507000e / 0x00000fff000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | encoding-defined | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setret_48_302bb793a800 | imm32 | 32 | 0–4294967295 | none | none | 32-bit immediate value | Encoded zero supplies numeric zero for the 32-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm32 | 32-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractOperation_HL_SETRET() => ScalarOperation
begin
    return ScalarOperation_HL_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETRET.asl -->
```asl
readonly func InstructionContractHandler_HL_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_HL_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_HL_SETRET(
    base: Word,
    halfword_offset: Word)
    => Word
begin
    return base + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.setret imm, ->Ra
