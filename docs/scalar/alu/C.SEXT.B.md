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
## What C.SEXT.B does

`C.SEXT.B` takes the low byte of one Reg5 source, sign-extends it to `PTO_XLEN`, and pushes the result to `T` as the newest temporary value.

Design point: the compressed extension forms have no destination field, so every successful execution produces exactly one `T` entry. The byte, halfword and word variants differ only in the position of the sign bit, which is why three mnemonics share one mechanism.

<!-- PTO-READER-BLOCK: scalar-c-sext-b-mechanism role=mechanism -->
## How the result is formed

Source bits `7..0` become result bits `7..0`, and source bit `7` is copied into every bit from `8` upward.

Design point: the sign bit is chosen by the mnemonic, not by a field, so there is no way to ask for a zero-extension here. A program that wants the unsigned byte uses the zero-extending member of the family or masks the value with `ANDI`.

Design point: the push shifts the queue rather than overwriting a slot, so the new value becomes `T#1` and the previous `T#4` is discarded.

<!-- PTO-READER-BLOCK: scalar-c-sext-b-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: a temporary source is legal, so `c.sext.b t#1, ->t` sign-extends the old `T#1` and pushes the result while the old value moves to `T#2`. The source queue is read, never popped.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, whose low byte is `0`, so `c.sext.b zero, ->t` pushes `0`.

<!-- PTO-READER-BLOCK: scalar-c-sext-b-effects role=effects -->
## Effects and ordering

The source is read before the push, so the instruction cannot observe the value it is about to create.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-c-sext-b-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` code is assigned and fixed encoding bits must match the canonical form, so `C.SEXT.B` has no reserved operand value.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: extension is total, so `C.SEXT.B` never faults on a source value. Every one of the `256` possible low bytes produces a defined XLEN result.

<!-- PTO-READER-BLOCK: scalar-c-sext-b-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0=255`, the low byte is `255`, its sign bit is set, and `c.sext.b a0, ->t` pushes `18446744073709551615`. With `a0=127`, the sign bit is clear and the pushed value is `127`.
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
