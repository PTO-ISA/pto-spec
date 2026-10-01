<!-- GENERATED FROM: asl/scalar/alu/REV.asl -->
# REV

**Normative ASL source:** `asl/scalar/alu/REV.asl`

REV reverses the bytes of an independently selected wrapping scalar field, zero-fills high result bits, and returns zero for a non-byte width.

## Normative identity {#PTO-INST-SCALAR-REV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-rev-purpose role=purpose -->
## What REV does

`REV` selects an `N`-bit field of `SrcL` that starts at bit `M` and wraps around bit `63`, reverses the bytes of that field, and publishes the reversed bytes in result bits `N-1:0`. It has four fields: `RegDst` at `[7 +: 5]`, `SrcL` at `[15 +: 5]`, `imml` at `[20 +: 6]` and `immr` at `[26 +: 6]`.

The carrier matches `0x00007067` under mask `0x0000707f`. `imml` encodes the width minus one and `immr` encodes the starting bit directly, so both fields use their full six-bit domain.

Both of its non-register fields are operand values: the width and the starting bit are independent, unlike the transformation forms such as `OR` where the two fields are a transformation selector and a shift amount.

<!-- PTO-READER-BLOCK: scalar-rev-mechanism role=mechanism -->
## How the reversal is formed

Dispatch calls `ReverseBitfieldBytes` with the snapshotted `SrcL`, the decoded width and the decoded `immr` offset (`asl/scalar/model/dispatch/alu.asl:385-391`). The helper tests `width MOD 8` first and returns `Zeros{PTO_XLEN}` immediately when the width is not a multiple of eight. Otherwise it extracts the field with `ExtractBitfield` and copies `field[(byte_index * 8) +: 8]` into `result[(((byte_count - 1) - byte_index) * 8) +: 8]` (`asl/scalar/model/alu/semantics.asl:194-205`).

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

Design point: `ExtractBitfield` rotates `SrcL` right by `M` and keeps the low `N` bits, which is why the selected field wraps: a field that runs past bit `63` continues at bit `0`. The extraction is unsigned, so no sign bit enters the reversal.

Design point: The modulo check runs before anything is extracted, so a width such as `7` is a legal encoding with a defined answer of zero rather than an illegal instruction.

<!-- PTO-READER-BLOCK: scalar-rev-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` is the only register operand. `imml` and `immr` are decoded from the carrier, and `RegDst` receives the result.

- `SrcL`, instruction slice `[15 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, and the read does not consume an entry.
- `imml`, instruction slice `[20 +: 6]`: raw values `0` through `63` select widths `1` through `64`, so encoded zero selects `N = 1`.
- `immr`, instruction slice `[26 +: 6]`: the starting bit `M`, `0` through `63`; encoded zero starts the field at source bit zero.
- `RegDst`, instruction slice `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.

Design point: The helper builds its answer from `Zeros{PTO_XLEN}`, so bits outside the selected field never reach the result.

<!-- PTO-READER-BLOCK: scalar-rev-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before the destination effect, so a destination that aliases the source reverses the pre-instruction value. The result is published and `TPC` advances by `4` bytes.

`REV` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege or control-flow state. A `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: Bits above `N-1` of the published word are zero, and for `N = 64` the reversal occupies the whole `PTO_XLEN` word.

<!-- PTO-READER-BLOCK: scalar-rev-constraints role=constraints -->
## Legality and fault boundary

All `64` `imml` values, all `64` `immr` values, all `32` `SrcL` codes and all `32` `RegDst` codes are assigned. The form has no constraint entry; the only fixed requirement is that the carrier bits outside the fields match `0x00007067`.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `REV` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: A width that is not a multiple of eight completes normally with a zero result, so `REV` has no operand-selected trap. The fault boundary is encoding validity and source availability.

<!-- PTO-READER-BLOCK: scalar-rev-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `0x1122334455667788`, `immr = 8` and `N = 32`, the selected field is `0x44556677` and `rev a0, 8, 32, ->a2` publishes `0x77665544`: the field byte that starts at source bit `8` moves to result bits `31:24`, and the other three follow in source order.

With the same source and `immr = 8` but `N = 7`, the width is not a multiple of `8`, so `rev a0, 8, 7, ->a2` publishes `0`. Source bits above the selected field never appear in either result.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | L32 | 32 | 0x00007067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| rev_32_58badc109d49 | immr | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| rev_32_58badc109d49 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| rev_32_58badc109d49 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| rev_32_58badc109d49 | immr | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| immr | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractOperation_REV()
    => ScalarOperation
begin
    return ScalarOperation_REV;
end;

pure func InstructionContractWidth_REV(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_REV(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractHandler_REV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;

pure func InstructionContractResult_REV(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ReverseBitfieldBytes(
        value,
        width,
        offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, immr, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- immr directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and immr value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. If N is a multiple of eight, reverse the selected bytes into result bits N-1:0 and zero-fill higher bits; otherwise return zero normally.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- A width that is not a multiple of eight is assigned and completes normally with a zero result; it is not an illegal instruction.

## Examples

- rev a0, 0, 64, ->a1
- rev u#1, 60, 16, ->t
- rev a0, 0, 7, ->zero
