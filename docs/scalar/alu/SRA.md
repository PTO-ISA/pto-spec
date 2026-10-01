<!-- GENERATED FROM: asl/scalar/alu/SRA.asl -->
# SRA

**Normative ASL source:** `asl/scalar/alu/SRA.asl`

SRA performs a arithmetic right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SRA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sra-purpose role=purpose -->
## What SRA does

`SRA` shifts `SrcL` arithmetically right by the amount in the low six bits of `SrcR`, copying the sign bit into the vacated positions, and publishes the full `PTO_XLEN` result. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00006005` under mask `0xfe00707f`.

The arithmetic shift is the only difference from `SRL`: the vacated left bits repeat `SrcL[63]` instead of being filled with zeros.

<!-- PTO-READER-BLOCK: scalar-sra-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ScalarBinary(ScalarBinary_SRA, left, right)` through the simple-binary path at `asl/scalar/model/dispatch/alu.asl:184-185`. The helper returns `ASR(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:458`), so the count is the low six bits of the snapshotted right source and the shift runs at full width.

```asm
sra SrcL, SrcR, ->{t, u, Rd}
```

Design point: Filling with copies of bit `63` makes `SRA` the right shift that preserves the sign of a two's-complement value: shifting a negative value right keeps it negative. `SRA` with `SrcL` holding `-16` and a count of `2` publishes `-4`.

Design point: A count of `63` leaves the sign bit repeated in every position. For a negative `SrcL` that is the all-ones word, and for a non-negative `SrcL` it is `0`.

<!-- PTO-READER-BLOCK: scalar-sra-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `SrcR` the count source, and `RegDst` the destination.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming.
- `SrcR`, instruction slice `[20 +: 5]`: count source, same map; every value is legal and only bits `5:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0` and therefore an identity shift.

Design point: Only the register that supplies the count is masked; the shifted value is used at full `PTO_XLEN` width, so bit `63` governs the fill. A value whose upper half is zero behaves like an unsigned shift.

<!-- PTO-READER-BLOCK: scalar-sra-effects role=effects -->
## Effects and ordering

Both sources are read before the destination write, so aliasing destinations shift pre-instruction values. The result is published and `TPC` advances by `4` bytes.

`SRA` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state. The only queue movement is the push selected by a `30` or `31` destination.

Design point: The shift never sets a sticky flag, so a signed value that becomes `-1` after a long shift is indistinguishable, from the architectural state, from a value that was `-1` before.

<!-- PTO-READER-BLOCK: scalar-sra-constraints role=constraints -->
## Legality and fault boundary

Every source code and every destination code of the Reg5 domain is assigned, and the form has no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRA` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: The arithmetic shift is total for every operand pair, including a count whose low six bits are zero. No operand value selects a trap in `SRA`.

<!-- PTO-READER-BLOCK: scalar-sra-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `-16` and `a1` holding `2`, `sra a0, a1, ->a2` publishes `-4`.

With `a0` holding `-1` and `a1` holding `63`, the sign bit is copied into every position, so `a2` receives `-1`. With `a0` holding `16` and the same count, `a2` receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sra SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | L32 | 32 | 0x00006005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sra_32_ba03eea6386b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sra_32_ba03eea6386b | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sra_32_ba03eea6386b | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractOperation_SRA()
    => ScalarOperation
begin
    return ScalarOperation_SRA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractHandler_SRA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRA(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRA(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRA(right);
    let shifted = ASR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRA()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low six bits of the snapshotted SrcR select the shift amount 0 through 63; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low six bits contribute to the shift amount.

## State effects

- Compute the arithmetic right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRA raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sra a0, a1, ->a2
- sra t#1, u#1, ->u
- sra zero, zero, ->zero
