<!-- GENERATED FROM: asl/scalar/alu/SLLW.asl -->
# SLLW

**Normative ASL source:** `asl/scalar/alu/SLLW.asl`

SLLW performs a logical left shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SLLW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sllw-purpose role=purpose -->
## What SLLW does

`SLLW` shifts the low `32` bits of `SrcL` logically left by an amount taken from the low five bits of `SrcR` and publishes the `32`-bit result sign-extended to `PTO_XLEN`. It has three fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`.

The carrier matches `0x00007025` under mask `0xfe00707f` and routes to `ScalarBinaryW`.

The word form uses five count bits, matching the width of the word, so the largest encodable shift is `31`.

<!-- PTO-READER-BLOCK: scalar-sllw-mechanism role=mechanism -->
## How the word shift is formed

Dispatch calls `ExecuteDecodedSimpleBinary` with `ScalarBinary_SLL` and `word_operation` true (`asl/scalar/model/dispatch/alu.asl:178-179`). `ScalarBinaryW` binds `left32` to `left[31:0]` and `right32` to `right[31:0]`, shifts with `LSL(left32, UInt(right[4:0]))`, and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:481`).

```asm
sllw SrcL, SrcR, ->{t, u, Rd}
```

Design point: Only the low five bits of `SrcR` become the amount. A count register holding `32` therefore shifts by `0`, because `32` is `0b100000` and bit `5` is outside the used field; the shift cannot exceed `31`.

Design point: The shift operates on the word before the sign extension, so bits that leave bit `31` are gone and the upper half of the published value is a copy of result bit `31`.

<!-- PTO-READER-BLOCK: scalar-sllw-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the shifted value, `SrcR` supplies the count, and `RegDst` receives the sign-extended word.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only `SrcL[31:0]` participates.
- `SrcR`, instruction slice `[20 +: 5]`: the count source, same five-bit map. Every value is legal; only bits `4:0` are used.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcR` reads the architectural zero GPR, which supplies amount `0`.

Design point: Because the count is masked to five bits rather than reduced modulo the word width by a separate rule, a count of `33` shifts by `1`. The count is a raw pattern, and the instruction does not compare it with `32`.

<!-- PTO-READER-BLOCK: scalar-sllw-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the write, so a destination aliasing either source shifts pre-instruction values. The result is published and `TPC` advances by `4` bytes.

`SLLW` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: `SLLW` records no numeric status. The discarded high bits of the word leave no trace, so a consumer that needs to know whether information was lost has to compare values itself.

<!-- PTO-READER-BLOCK: scalar-sllw-constraints role=constraints -->
## Legality and fault boundary

Every `SrcL`, `SrcR` and `RegDst` code is assigned, and the form carries no constraint entry beyond the fixed carrier bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SLLW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. All checks precede the destination effect and the `TPC` advance.

Design point: The word shift and the sign extension are total over every operand value, so no operand value selects a trap in `SLLW`; apart from the block-applicability check above, its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-sllw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `1` and `a1` holding `4`, `sllw a0, a1, ->a2` publishes `16`.

With `a0` holding `1` and `a1` holding `33`, the amount is reduced to the low five bits, which are `1`, so `a2` receives `2`. With a low-word source of `0x80000000` and a count of `1`, the word result is `0` and `a2` receives `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sllw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sllw_32_a37b63c16b27 | L32 | 32 | 0x00007025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sllw_32_a37b63c16b27 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sllw_32_a37b63c16b27 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sllw_32_a37b63c16b27 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sllw_32_a37b63c16b27 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sllw_32_a37b63c16b27 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sllw_32_a37b63c16b27 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractOperation_SLLW()
    => ScalarOperation
begin
    return ScalarOperation_SLLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractHandler_SLLW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SLLW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SLLW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SLLW(right);
    let shifted = LSL(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SLLW()
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

- Compute the logical left shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLLW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sllw a0, a1, ->a2
- sllw t#1, u#1, ->u
- sllw zero, zero, ->zero
