<!-- GENERATED FROM: asl/scalar/alu/C.SRLI.asl -->
# C.SRLI

**Normative ASL source:** `asl/scalar/alu/C.SRLI.asl`

C.SRLI snapshots the pre-instruction T#1 value, logically shifts it right by uimm5, and pushes the XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-srli-purpose role=purpose -->
## What C.SRLI does

`C.SRLI` shifts the pre-instruction `T#1` value logically right and pushes the XLEN result to `T`. Both the source and the destination are fixed by the mnemonic; the 16-bit form encodes only the shift amount.

Design point: the compressed encoding has no source field and no destination field, so every `c.srli` reads `T#1` and replaces the newest `T` entry. A program that needs the shifted value in a GPR must move it there afterwards, because the form cannot name one.

<!-- PTO-READER-BLOCK: scalar-c-srli-mechanism role=mechanism -->
## How the result is formed

`uimm5` is zero-extended to XLEN and passed as the right operand of the shared logical-right-shift rule. Bits shifted out below bit zero are discarded and vacated high bits are filled with zeros.

Design point: the shared shift rule takes the amount from the low six bits of its right operand, so a five-bit field can reach `0..31` and no further. The 32-bit `SRLI` spends six bits on `shamt` and reaches `0..63`; the compressed form cannot.

Design point: encoded zero is a real shift by zero, not an omitted operand, so `c.srli t#1, 0, ->t` publishes the unchanged value as a new `T` entry. The queue still moves: the copy becomes `T#1` and the previous `T#4` is discarded.

<!-- PTO-READER-BLOCK: scalar-c-srli-inputs role=inputs-outputs -->
## Inputs and destinations

- `T#1` is the fixed source, read as a complete XLEN value and snapshotted before the push.
- `uimm5` is the only encoded field: an unsigned five-bit shift amount from `0` through `31`.
- The destination is fixed to `T`: exactly one XLEN result per successful execution.

Relative reads do not consume a queue entry, so the value this instruction read is still available to later instructions.

<!-- PTO-READER-BLOCK: scalar-c-srli-effects role=effects -->
## Effects and ordering

The old `T#1` is snapshotted before the destination push, so the instruction never shifts its own result. The push moves the queue toward older indices, and the new value becomes `T#1`.

After the push, `TPC` advances by `2` bytes. No GPR is written, and no `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or other control state changes.

<!-- PTO-READER-BLOCK: scalar-c-srli-constraints role=constraints -->
## Legality and fault boundary

Every `uimm5` value from `0` through `31` is assigned, and the fixed encoding bits of the canonical form must match exactly. The logical shift is total and raises no arithmetic exception for any amount.

An uninitialized `T#1` raises `Fault_IllegalInstruction` before the push, before `TPC` advances and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`.

Design point: `T#1` is an implicit source, so its availability is checked by the implicit-source rule instead of by an encoded source selector, and this form has no encoded source selector to check. The form-constraint, encoded-register and implicit-source preflights all run before the operation, which is why a missing `T#1` cannot leave a partial effect.

<!-- PTO-READER-BLOCK: scalar-c-srli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `16`, the encoding `c.srli t#1, 2, ->t` pushes `4` and leaves the old `16` in `T#2`. The canonical example `c.srli t#1, 31, ->t` pushes `0` or `1`, namely the old value of bit `31`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.srli t#1, uimm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | C16 | 16 | 0x182c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_srli_16_b411862f7820 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit logical right-shift amount | Encoded zero republishes the unchanged pre-instruction T#1 value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit logical right-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SRLI.asl -->
```asl
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SRLI(
    old_t1: Word,
    encoded_amount: bits(5))
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SRL,
        old_t1,
        ZeroExtend{PTO_XLEN}(encoded_amount));
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- T#1 is the fixed source and T is the fixed destination; neither is encoded or omittable in canonical assembly.
- uimm5 is required and directly encodes a shift amount from 0 through 31.

## Legality

- Every uimm5 value 0..31 is assigned. Fixed encoding bits must match the canonical form.
- The fixed T#1 source must be initialized before execution.

## State effects

- Logically shift the complete XLEN old T#1 value right by UInt(uimm5); shifted-out bits are discarded and vacated bits are zero-filled.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices and the former T#4 is discarded.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot old T#1 before the destination push, so the instruction cannot read its own result.
- Push the shifted result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- The logical shift is total and raises no arithmetic exception.
- If T#1 is unavailable, Fault_IllegalInstruction is raised before the T push, before TPC advances, and before any other effect.

## Examples

- c.srli t#1, 31, ->t
