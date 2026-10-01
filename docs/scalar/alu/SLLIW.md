<!-- GENERATED FROM: asl/scalar/alu/SLLIW.asl -->
# SLLIW

**Normative ASL source:** `asl/scalar/alu/SLLIW.asl`

SLLIW performs a word logical left shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SLLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-slliw-purpose role=purpose -->
## What SLLIW does

`SLLIW` shifts the low `32` bits of `SrcL` logically left by a constant `shamt` of `0` through `31` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the five-bit `shamt` at `[20 +: 5]`.

The carrier matches `0x00007035` under mask `0xfe00707f`; bits `31:25` are fixed, so the amount is exactly five bits wide.

The result is reconstructed by sign extension rather than zero extension, which is why a shift that sets bit `31` publishes an all-ones upper half.

<!-- PTO-READER-BLOCK: scalar-slliw-mechanism role=mechanism -->
## How the word result is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `ScalarBinary_SLL` and `word_operation` true (`asl/scalar/model/dispatch/alu.asl:190-191`). `ScalarBinaryW` binds `left32` to `left[31:0]`, shifts with `UInt(right[4:0])`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:470-487`).

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

Design point: The mask and the helper agree on five bits: the encodable amounts are `0` through `31`, and the helper would discard any higher bit of the count anyway. No encoding can request a shift of a whole word.

Design point: Bits shifted past bit `31` of the word are discarded before the sign extension, so they cannot reappear in the upper half. The published upper half is always a copy of result bit `31`.

<!-- PTO-READER-BLOCK: scalar-slliw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` supplies the word, `shamt` is decoded from the carrier, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `shamt`, instruction slice `[20 +: 5]`: `0` through `31`; encoded zero performs an identity word shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, so a zero source publishes `0`.

Design point: A source whose low word is `1` and whose upper half is nonzero still shifts only the low word: with `a0 = 0xFFFFFFFF00000001`, `slliw a0, 4, ->a2` publishes `16`, because the upper half of the source is dropped before the shift.

<!-- PTO-READER-BLOCK: scalar-slliw-effects role=effects -->
## Effects and ordering

`SrcL` is read before the write, so an aliasing destination shifts the pre-instruction value. The sign-extended word is published and `TPC` advances by `4` bytes.

`SLLIW` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state. The only queue movement is the push selected by a `30` or `31` destination.

Design point: The narrowing happens before the shift, not after, so an upper-half bit of `SrcL` can never be shifted down into the result. `SLLIW` is therefore a complete word operation rather than a `PTO_XLEN` shift followed by truncation.

<!-- PTO-READER-BLOCK: scalar-slliw-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `32` shift amounts are assigned. The form has no constraint entry beyond the fixed bits `31:25` and `14:12`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SLLIW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: Neither the word shift nor the final sign extension faults, so `SLLIW` has no operand-selected trap. Apart from the block-applicability check above, its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-slliw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `1`, `slliw a0, 4, ->a2` publishes `16`.

With `a0` holding `1`, `slliw a0, 31, ->a2` publishes `0xFFFFFFFF80000000`, because word bit `31` is set and the final extension copies it through the upper half.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | L32 | 32 | 0x00007035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slliw_32_c6bf463b97ae | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| slliw_32_c6bf463b97ae | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractOperation_SLLIW()
    => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractHandler_SLLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SLLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SLLIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit logical left shift LSL(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SLLIW raises no arithmetic exception; shifted-out word bits are discarded and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slliw a0, 1, ->a0
- slliw u#1, 31, ->t
- slliw zero, 0, ->zero
