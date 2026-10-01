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
## What J does

`J` transfers control to a PC-relative target. Its displacement is signed and counts halfwords, and it is applied to the address of the `J` instruction itself.

Design point: `J` writes `TPC` directly and the dispatch boundary adds no sequential advance afterwards, so the jump replaces the continuation instead of being applied on top of it.

<!-- PTO-READER-BLOCK: scalar-j-mechanism role=mechanism -->
## Target computation

`simm22` is sign-extended to `PTO_XLEN` and shifted left by `1`, and the sum with the current `PC` becomes the new `PC`. The addition is `64` bits wide and wraps at `2^64`.

Design point: the displacement is measured from the address of `J` itself rather than from the following instruction, so the encoded value `0` produces a self-loop that re-executes the same jump.

Design point: `JumpRelative` performs no test on the computed target, so an accepted `J` always installs its target; the target-parity check belongs to the register jump `JR`, not to `J`.

<!-- PTO-READER-BLOCK: scalar-j-inputs-outputs role=inputs-outputs -->
## Operands and result

- `simm22` supplies the signed halfword displacement. It is encoded in two instruction pieces, `17` bits and `5` bits wide.

- The base of the computation is the current `PC`, read inside the handler. `J` has no register operand and no immediate base operand.

- The only output is the new `PC`. No register, queue entry, or memory location is written.

<!-- PTO-READER-BLOCK: scalar-j-effects role=effects -->
## Control-flow effect

`WritePC` replaces the program counter with the computed target, so the next instruction is fetched from the target. Because `JumpRelative` is one of the handlers that writes `TPC`, the dispatch boundary does not add the `4`-byte length of this `32`-bit form.

`J` writes no register, no queue entry, no memory location, no commit argument, and no `BARG` field. No Conditional-block placement is required for it, because it is not a condition setter.

<!-- PTO-READER-BLOCK: scalar-j-constraints role=constraints -->
## Legality and fault order

A pattern that does not match the fixed bits of the form raises `Fault_IllegalInstruction` and leaves `TPC` unchanged. No field value is reserved: every `simm22` value is assigned, including `0`.

Design point: the displacement is read from the instruction and the target is computed and installed in a single step, so a rejected decode cannot leave a half-applied control transfer behind.

<!-- PTO-READER-BLOCK: scalar-j-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

For a `J` at `0x4000`, `j 8` installs `0x4010` as the new `PC`, while the sequential continuation would have been `0x4004`. `j -3` installs `0x3FFA`, and `j 0` installs `0x4000`, re-executing the same jump.
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
