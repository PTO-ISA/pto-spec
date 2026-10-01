<!-- GENERATED FROM: asl/scalar/bru/SETRET.asl -->
# SETRET

**Normative ASL source:** `asl/scalar/bru/SETRET.asl`

SETRET - Write the architectural return address.

## Normative identity {#PTO-INST-SCALAR-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setret-purpose role=purpose -->
## What SETRET does

`SETRET` computes a return target from the current `TPC` and an encoded displacement, and records it in architectural and bundle-local return state.

It records the address without transferring control: the instruction does not branch to the target it computes, and the sequential path continues at the following instruction. A later control transfer must read `R10` or the retained bundle return state to use the recorded address.

<!-- PTO-READER-BLOCK: scalar-setret-mechanism role=mechanism -->
## How the target is computed

The immediate is zero-extended to the full word width, shifted left by `1` to scale a halfword offset into a byte offset, and added to the `TPC` read at execution time. The same computed word is written to GPR `R10`, the architectural return-address register, and to the bundle-local return address.

Design point: the shift is a fixed `1`, not a field, so the computed target is always even. A return site is therefore always halfword-aligned by construction and the program never has to mask the value before use.

Design point: the base is the `TPC` of this instruction, so the displacement is relative to the `SETRET` site itself rather than to the next instruction.

<!-- PTO-READER-BLOCK: scalar-setret-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `imm20` supplies the encoded displacement, treated as unsigned and scaled by `2`; encoded zero supplies numeric zero.
- The current `TPC` supplies the base address.
- The computed target is written to GPR `R10` and to the retained bundle return state.

<!-- PTO-READER-BLOCK: scalar-setret-effects role=effects -->
## Effects and ordering

The target is published to `R10` and to the bundle-local return address as one update, and the instruction then retires along the normal sequential path with `TPC` advanced by `4` bytes.

No memory, reservation, descriptor, numeric-status, or predicate state changes, and the instruction has no source operand whose readiness could be checked. Later writes to `R10` are ordinary GPR writes and are not coupled back to the bundle-local return address.

<!-- PTO-READER-BLOCK: scalar-setret-constraints role=constraints -->
## Which faults this instruction can raise

The instruction carries one unconstrained `20`-bit field, so every encoding of that field is assigned and no field value is reserved. A fixed-bit mismatch raises `Fault_IllegalInstruction` before any effect.

`SETRET` has no encoded register operand to validate and no memory access, and `SetReturnAddress` raises no fault of its own. Apart from the applicability check that every scalar form passes, a mismatch of the fixed bits is the only fault this encoding can add.

<!-- PTO-READER-BLOCK: scalar-setret-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

At `TPC=1000`, execute the form whose encoded field is `imm20=64`. The displacement scales to `128`, so `R10` and the bundle-local return address both receive `1128`, and execution continues with `TPC=1004`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setret uimm, ->Ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | L32 | 32 | 0x00000507 / 0x00000fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setret_32_72003dcf3b59 | imm20 | 20 | encoding-defined | [{"instruction_lsb":12,"value_lsb":0,"width":20}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setret_32_72003dcf3b59 | imm20 | 20 | 0–1048575 | none | none | 20-bit immediate value | Encoded zero supplies numeric zero for the 20-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm20 | 20-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractOperation_SETRET() => ScalarOperation
begin
    return ScalarOperation_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETRET.asl -->
```asl
readonly func InstructionContractHandler_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractUsesTPC_SETRET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_SETRET(
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

- SETRET - Write the architectural return address.
- After decode and legality checks, execute the normative SetReturnAddress ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- setret uimm, ->Ra
