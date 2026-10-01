<!-- GENERATED FROM: asl/scalar/alu/C.OR.asl -->
# C.OR

**Normative ASL source:** `asl/scalar/alu/C.OR.asl`

C.OR snapshots two complete Reg5 sources, computes the bitwise inclusive OR of SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-or-purpose role=purpose -->
## What C.OR does

`C.OR` reads two Reg5 sources, computes their bit-by-bit inclusive OR over all `PTO_XLEN` bits, and pushes the result to `T` as the newest temporary value.

Design point: `C.OR` is the setting counterpart of `C.AND` in the same compressed shape. Both take the operation from the opcode and both operands from the two available fields, so neither can transform a source; the transforming forms are the 32-bit `OR` family.

<!-- PTO-READER-BLOCK: scalar-c-or-mechanism role=mechanism -->
## How the result is formed

Both source codes are resolved, the inclusive OR is computed for each of the `64` bit positions, and the result is pushed as the newest `T` entry.

Design point: the push shifts the queue rather than overwriting a slot, so the new value becomes `T#1`, the previous `T#1` becomes `T#2`, and the previous `T#4` is discarded.

Design point: an inclusive OR can only set bits relative to its sources, so a bit that is clear in the result is clear in both sources. Combining fields with `C.OR` therefore never clears a bit that either input had set.

Design point: because both sources are read before the push, `c.or t#1, t#1, ->t` pushes a copy of the old `T#1` as a new entry and moves the original to `T#2`. The queue grows a duplicate instead of the instruction reading its own result.

<!-- PTO-READER-BLOCK: scalar-c-or-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` and `SrcR` are Reg5 sources: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: duplicate and mixed source pairs are legal and every source code is assigned. Only an unavailable selected temporary prevents the push.

Design point: encoded zero of one source reads the architectural zero GPR, so `c.or a0, zero, ->t` pushes a copy of `a0` and `c.or zero, zero, ->t` pushes `0`. An inclusive OR with zero is the compressed copy operation.

<!-- PTO-READER-BLOCK: scalar-c-or-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the `T` push, so a source that names a queue entry sees the pre-instruction queue.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no source queue entry is consumed.

<!-- PTO-READER-BLOCK: scalar-c-or-constraints role=constraints -->
## Legality and fault boundary

Every encoded source value is assigned, so `C.OR` has no reserved source code.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: bitwise inclusive OR is total, so `C.OR` has no value-dependent fault and no status flag. Setting a bit another part of the program owns is a programming error, not an exception.

<!-- PTO-READER-BLOCK: scalar-c-or-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `12` and `U#1` holding `10`, `c.or t#1, u#1, ->t` pushes `12 OR 10 = 14` to `T#1`, moves the old value `12` to `T#2`, and leaves `U#1` at `10`. With `SrcR` naming the architectural zero GPR and `SrcL=15`, the pushed value is `15`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.or srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | C16 | 16 | 0x0038 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_or_16_90864d13a661 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_or_16_90864d13a661 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_or_16_90864d13a661 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractOperation_C_OR() => ScalarOperation
begin
    return ScalarOperation_C_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.OR.asl -->
```asl
readonly func InstructionContractHandler_C_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_OR(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_OR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required encoded fields; neither source can be omitted.
- The destination is not encoded: every successful form pushes exactly one result to T.

## Legality

- Each source code 0..23 selects an absolute GPR, 24..27 selects T#1..T#4, and 28..31 selects U#1..U#4 without consumption.
- Duplicate, absolute-relative, and relative-relative source pairs are legal. Every encoded source value is assigned.

## State effects

- Compute bitwise OR on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Bitwise or is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.or t#1, u#1, ->t
