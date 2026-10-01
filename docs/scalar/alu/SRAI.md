<!-- GENERATED FROM: asl/scalar/alu/SRAI.asl -->
# SRAI

**Normative ASL source:** `asl/scalar/alu/SRAI.asl`

SRAI performs an XLEN arithmetic right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRAI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srai-purpose role=purpose -->
## What SRAI does

`SRAI` shifts `SrcL` arithmetically right by a constant `shamt` of `0` through `63`, copying the sign bit into the vacated positions. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and the six-bit `shamt` at `[20 +: 6]`.

The carrier matches `0x00006015` under mask `0xfc00707f`.

The mnemonic keeps the full `PTO_XLEN` width: the sign bit that is copied is always bit `63`, and no field selects a narrower width.

<!-- PTO-READER-BLOCK: scalar-srai-mechanism role=mechanism -->
## How the shift is formed

Dispatch calls `ExecuteDecodedShiftImmediate` with `ScalarBinary_SRA` at `asl/scalar/model/dispatch/alu.asl:196-197`. The decoded `shamt` becomes the right operand and `ScalarBinary` returns `ASR(left, UInt(right[5:0]))` (`asl/scalar/model/alu/semantics.asl:458`).

```asm
srai SrcL, shamt, ->{t, u, Rd}
```

Design point: Because the shift is arithmetic at `64` bits, the result is the floor of the signed value divided by two to the power of `shamt`, not the truncated quotient toward zero. `SRAI` with `-1` and any amount from `1` through `63` publishes `-1`.

Design point: The amount is a constant in the encoding, so the shift is a fixed field extraction: with `shamt = 8` the published value is `SrcL[63:8]` read as a signed `56`-bit field, whose upper `8` bits are copies of `SrcL[63]`.

<!-- PTO-READER-BLOCK: scalar-srai-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the value shifted, `shamt` is decoded from the carrier, and `RegDst` receives the result.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read never consumes an entry.
- `shamt`, instruction slice `[20 +: 6]`: `0` through `63`; encoded zero performs an identity shift.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` reads the architectural zero GPR, which has a clear sign bit, so every amount publishes `0`.

Design point: The sign source is fixed by the form, not selectable. A program that needs the sign of a narrower field must first place that field's top bit at bit `63`, for example with a shift pair, because `SRAI` has no width selector.

<!-- PTO-READER-BLOCK: scalar-srai-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that aliases the source shifts the pre-instruction value. The result is published and `TPC` advances by `4` bytes.

`SRAI` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; the only queue movement possible is the push selected by a `30` or `31` destination.

Design point: The instruction neither reports nor records whether bits were shifted out. Its whole architectural effect is the one published word.

<!-- PTO-READER-BLOCK: scalar-srai-constraints role=constraints -->
## Legality and fault boundary

All `32` `SrcL` codes, all `32` `RegDst` codes and all `64` shift amounts are assigned, and the form has no constraint entry beyond the fixed bits `31:26` and `14:12`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`, which also rejects a nonzero bit of the reserved `31:26` field. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRAI` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. All checks precede the destination effect and the `TPC` advance.

Design point: Since every encodable shift amount has a defined result, `SRAI` has no operand-selected trap. Apart from the block-applicability check above, its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-srai-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `-16`, `srai a0, 2, ->a2` publishes `-4`.

With `a0` holding `0x00000000000000FF` and an amount of `4`, the result is `15`. With `a0` holding `-1`, every amount from `1` through `63` publishes `-1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srai SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | L32 | 32 | 0x00006015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srai_32_e471ea84d4fd | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srai_32_e471ea84d4fd | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractOperation_SRAI()
    => ScalarOperation
begin
    return ScalarOperation_SRAI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractHandler_SRAI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRAI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRAI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN arithmetic right shift ASR(SrcL, shamt), inserting copies of the source sign bit at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRAI raises no arithmetic exception; shifted-out bits are discarded and copies of SrcL[PTO_XLEN-1] enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srai a0, 1, ->a0
- srai t#1, 63, ->u
- srai zero, 0, ->zero
