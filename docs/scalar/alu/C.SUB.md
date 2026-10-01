<!-- GENERATED FROM: asl/scalar/alu/C.SUB.asl -->
# C.SUB

**Normative ASL source:** `asl/scalar/alu/C.SUB.asl`

C.SUB snapshots two complete Reg5 sources, subtracts SrcR from SrcL modulo 2^XLEN, and pushes the result to T.

## Normative identity {#PTO-INST-SCALAR-C-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-sub-purpose role=purpose -->
## What C.SUB does

`C.SUB` reads two Reg5 sources, computes `SrcL` minus `SrcR` modulo `2^PTO_XLEN`, and pushes the XLEN difference to `T`.

Design point: ten of the sixteen encoded bits are the two 5-bit source selectors, and none are a destination selector, so both operands can vary while the result always lands in the newest `T` entry. A compressed subtraction cannot write a GPR directly.

<!-- PTO-READER-BLOCK: scalar-c-sub-mechanism role=mechanism -->
## How the result is formed

Both sources are snapshotted first, then subtracted with fixed-width arithmetic that wraps modulo `2^PTO_XLEN`. A negative difference is published as its two's-complement bit pattern.

Design point: because the published value is a complete XLEN two's-complement number, `c.sub zero, a0, ->t` publishes `0 - a0`. The mnemonic needs no second operand form to express a negation.

Design point: subtraction is ordered, so the two selector fields are not interchangeable: `c.sub a0, a1, ->t` and `c.sub a1, a0, ->t` push different values. Both encodings are legal and both sources are read before the push.

<!-- PTO-READER-BLOCK: scalar-c-sub-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the left Reg5 source and `SrcR` the right one: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, without consuming a queue entry.
- The destination is fixed to `T`: exactly one XLEN result per successful execution.

Design point: the zero code of either source reads the architectural zero GPR, so `c.sub a0, zero, ->t` republishes `a0` and `c.sub zero, zero, ->t` pushes `0` without depending on real register contents. Duplicate and mixed selectors are legal, so `c.sub t#1, u#1, ->t` is a valid encoding.

<!-- PTO-READER-BLOCK: scalar-c-sub-effects role=effects -->
## Effects and ordering

`SrcL` and `SrcR` are snapshotted before the destination push, so the instruction cannot subtract its own result and a destination alias cannot disturb an operand. The push moves the queue toward older indices, and the new value becomes `T#1`.

After the push, `TPC` advances by `2` bytes. No GPR is written, and no `U` entry, memory, reservation, descriptor, numeric-status, bundle, privilege, predicate or other control state changes.

<!-- PTO-READER-BLOCK: scalar-c-sub-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL` and `SrcR` code from `0` through `31` is assigned, so no source selector is reserved, and the six fixed encoding bits must match the canonical form. Fixed-width subtraction is total and raises no arithmetic exception, including on underflow.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the `T` push, before `TPC` advances and before any other effect. An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active bundle raises `Fault_BundleControl` at `TPC`.

Design point: source availability is decided by the two encoded selectors, before any subtraction happens. A `c.sub` that names an empty queue slot therefore faults instead of publishing a difference computed from a value the queue does not hold.

<!-- PTO-READER-BLOCK: scalar-c-sub-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `10` and `T#1` holding `7`, `c.sub a0, t#1, ->t` pushes `3` and moves the old `7` to `T#2`; the source queues are unchanged. With `a0` holding `0` and `a1` holding `1`, `c.sub a0, a1, ->t` pushes `2^PTO_XLEN - 1`, which reads as `-1` in two's complement.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.sub srcL, srcR, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sub_16_ff0056ac7053 | C16 | 16 | 0x0018 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sub_16_ff0056ac7053 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sub_16_ff0056ac7053 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sub_16_ff0056ac7053 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| c_sub_16_ff0056ac7053 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SUB.asl -->
```asl
readonly func InstructionContractOperation_C_SUB() => ScalarOperation
begin
    return ScalarOperation_C_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SUB.asl -->
```asl
readonly func InstructionContractHandler_C_SUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_C_SUB(
    left: Word,
    right: Word)
    => Word
begin
    return ScalarBinary(
        ScalarBinary_SUB,
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

- Compute SrcL minus SrcR modulo 2^PTO_XLEN; underflow wraps.
- Push exactly one XLEN result to T. Existing T entries shift toward older indices, the former T#4 is discarded, and no source is consumed.
- No GPR, U queue, memory, reservation, descriptor, numeric-status, block, privilege, predicate, or other control state changes. Successful execution advances TPC by two bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before pushing the destination so aliases observe the pre-instruction queue state.
- Push the result as the newest T entry, then advance TPC by two bytes.

## Exceptions

- Ordered subtraction is a total fixed-width operation and raises no arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the T push, before TPC advances, and before any other effect.

## Examples

- c.sub t#1, u#1, ->t
