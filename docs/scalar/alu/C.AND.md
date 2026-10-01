<!-- GENERATED FROM: asl/scalar/alu/C.AND.asl -->
# C.AND

**Normative ASL source:** `asl/scalar/alu/C.AND.asl`

C.AND snapshots two complete Reg5 sources, computes the bitwise conjunction of SrcL and SrcR, and pushes the wrapping XLEN result to T.

## Normative identity {#PTO-INST-SCALAR-C-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-and-purpose role=purpose -->
## What C.AND does

`C.AND` reads two Reg5 sources, computes their bit-by-bit conjunction over all `PTO_XLEN` bits, and pushes the result to `T` as the newest temporary value.

Design point: the compressed logical forms take their operation from the opcode and their two operands from the only two fields the 16-bit encoding has. There is no modifier field, so `C.AND` always uses the complete source values; the transforming forms are the 32-bit `AND` family.

<!-- PTO-READER-BLOCK: scalar-c-and-mechanism role=mechanism -->
## How the result is formed

Both source codes are resolved and the conjunction is computed independently for each of the `64` bit positions. The result is pushed as the newest `T` entry.

Design point: the push shifts the queue instead of overwriting a slot, so the new value becomes `T#1`, the previous `T#1` becomes `T#2`, and the previous `T#4` is discarded. A temporary survives four pushes.

Design point: a conjunction can only clear bits relative to its sources, so any bit set in the result is set in both sources. A mask built this way cannot acquire a bit that neither input had.

<!-- PTO-READER-BLOCK: scalar-c-and-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` and `SrcR` are Reg5 sources: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result is pushed per successful execution.

Design point: duplicate and mixed source pairs are legal, so `c.and t#1, u#1, ->t` and `c.and t#1, t#1, ->t` both encode. Since both sources are read before the push, the second form pushes the old `T#1` value paired with itself.

Design point: encoded zero of either source reads the architectural zero GPR, so `c.and a0, zero, ->t` pushes `0` and `c.and zero, zero, ->t` is a constant-zero push.

<!-- PTO-READER-BLOCK: scalar-c-and-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the `T` push, so an alias between a source and the queue observes the pre-instruction state.

After the push, `TPC` advances by `2` bytes. No GPR, `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state changes, and no source queue entry is consumed.

<!-- PTO-READER-BLOCK: scalar-c-and-constraints role=constraints -->
## Legality and fault boundary

Every encoded source value is assigned, so `C.AND` has no reserved source code and no illegal operand combination.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the push, before `TPC` advances, and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`.

Design point: a bitwise conjunction signals nothing and cannot overflow, so `C.AND` has no value-dependent fault and no status flag. Bits that the mask removes are simply absent from the pushed value.

<!-- PTO-READER-BLOCK: scalar-c-and-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `T#1` holding `12` and `U#1` holding `10`, `c.and t#1, u#1, ->t` pushes `12 AND 10 = 8` to `T#1`, moves the old value `12` to `T#2`, and leaves `U#1` at `10`. With `SrcR` naming the architectural zero GPR, the pushed value is `0` for every `SrcL`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.and srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_and_16_379e5bed3352 | C16 | 16 | 0x0028 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_and_16_379e5bed3352 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_and_16_379e5bed3352 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_and_16_379e5bed3352 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_and_16_379e5bed3352 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.AND.asl -->
```asl
readonly func InstructionContractOperation_C_AND() => ScalarOperation
begin
    return ScalarOperation_C_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.AND.asl -->
```asl
readonly func InstructionContractHandler_C_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_AND(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_AND,
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

- Compute bitwise AND on the two complete XLEN source values.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Bitwise and is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.and t#1, u#1, ->t
