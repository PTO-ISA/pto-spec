<!-- GENERATED FROM: asl/scalar/alu/SRAW.asl -->
# SRAW

**Normative ASL source:** `asl/scalar/alu/SRAW.asl`

SRAW performs a arithmetic right shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SRAW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraw-purpose role=purpose -->
## What SRAW does

`SRAW` shifts the low `32` bits of `SrcL` arithmetically right by an amount taken from the low five bits of `SrcR` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00006025` under mask `0xfe00707f`.

The sign source is word bit `31`, and the count source is truncated to five bits, so the two operand roles are treated asymmetrically.

<!-- PTO-READER-BLOCK: scalar-sraw-mechanism role=mechanism -->
## How the word shift is formed

Dispatch calls `ExecuteDecodedSimpleBinary` with `ScalarBinary_SRA` and `word_operation` true (`asl/scalar/model/dispatch/alu.asl:186-187`). `ScalarBinaryW` takes `left[31:0]`, shifts with `ASR(left32, UInt(right[4:0]))`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:483`).

```asm
sraw SrcL, SrcR, ->{t, u, Rd}
```

Design point: The count is the low five bits of the full snapshotted `SrcR`, not of a pre-truncated word. A count register holding `0x1000000020` supplies `0`, because bit `5` is outside the used field, while its low five bits are zero.

Design point: Because the shift happens on the word, the upper half of `SrcL` has no influence on the result. Only the word of the value and the low five bits of the count matter.

<!-- PTO-READER-BLOCK: scalar-sraw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `SrcR` supplies the count, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `SrcR`, instruction slice `[20 +: 5]`: the count source, same five-bit map; every value is legal and only bits `4:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0`.

Design point: A count whose low five bits are all ones shifts by `31`, which leaves the word sign bit repeated in every position of the word. The published value is then either `0` or the all-ones word, depending only on word bit `31` of `SrcL`.

<!-- PTO-READER-BLOCK: scalar-sraw-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination write, so a destination aliasing either source shifts pre-instruction values. The sign-extended word is published and `TPC` advances by `4` bytes.

`SRAW` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; the only queue movement is the push selected by a `30` or `31` destination.

Design point: `SRAW` reports nothing about how many bits left the word. Because the sign fill is deterministic, the published word is a complete description of the shift result.

<!-- PTO-READER-BLOCK: scalar-sraw-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL`, `SrcR` and `RegDst` code is assigned and no constraint entry applies beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SRAW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each check precedes the destination effect and the `TPC` advance.

Design point: The count field is entirely assigned and the word shift cannot fault, so `SRAW` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-sraw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0 = -16` and `a1 = 2`, `sraw a0, a1, ->a2` publishes `-4`.

With `a0` holding `0x0000000080000000` and `a1` holding `4`, the word is negative and the result word is `0xF8000000`, so `a2` receives `0xFFFFFFFFF8000000`. With `a1` holding `32`, the low five bits are `0` and `a2` receives the sign-extended word of `a0` unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraw_32_5baf37f34241 | L32 | 32 | 0x00006025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraw_32_5baf37f34241 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraw_32_5baf37f34241 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraw_32_5baf37f34241 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraw_32_5baf37f34241 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraw_32_5baf37f34241 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sraw_32_5baf37f34241 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractOperation_SRAW()
    => ScalarOperation
begin
    return ScalarOperation_SRAW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractHandler_SRAW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SRAW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SRAW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRAW(right);
    let shifted = ASR(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SRAW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low five bits of the snapshotted SrcR select the shift amount 0 through 31; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low five bits contribute to the shift amount.

## State effects

- Compute the arithmetic right shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRAW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sraw a0, a1, ->a2
- sraw t#1, u#1, ->u
- sraw zero, zero, ->zero
