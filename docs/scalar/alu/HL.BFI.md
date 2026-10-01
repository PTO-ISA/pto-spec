<!-- GENERATED FROM: asl/scalar/alu/HL.BFI.asl -->
# HL.BFI

**Normative ASL source:** `asl/scalar/alu/HL.BFI.asl`

HL.BFI inserts ascending low source bits into an inclusive wrapping destination interval of a snapshotted base value and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-HL-BFI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-bfi-purpose role=purpose -->
## What HL.BFI does

`HL.BFI` is a 48-bit scalar ALU instruction. It copies ascending bits of the insertion source, starting at source bit 0, into an inclusive interval of a snapshotted base value, and publishes one XLEN result.

Design point: the interval is named by two 6-bit fields and its width is `(((imms - immr) + 64) MOD 64) + 1`. Equal endpoints select one destination bit, and `imms` before `immr` wraps through bit 63 to bit 0.

<!-- PTO-READER-BLOCK: scalar-hl-bfi-mechanism role=mechanism -->
## How the result is formed

`InsertBitfield` copies the base, computes the width, and writes source bit `i` to destination bit `(first + i) MOD 64`, ascending from source bit 0 (`asl/scalar/model/alu/semantics.asl:311-321`).

The modulo is what wraps the interval: with `immr=63` and `imms=0` the width is `2`, so source bit 0 lands on bit 63 and source bit 1 on bit 0.

Design point: the result starts as a copy of the base, so only the selected positions change; `immr=1, imms=0` selects all `64` bits and replaces the whole value, while a narrow interval keeps the other base bits and leaves higher source bits unused.

<!-- PTO-READER-BLOCK: scalar-hl-bfi-inputs role=inputs-outputs -->
## Inputs and destinations

- `RegDst` selects the Reg5 result target or discards the result.
- `SrcL` is the base source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, `28..31` select `U#1..U#4`.
- `SrcR` is the insertion source and uses the same map.
- `immr` is the 6-bit first destination bit.
- `imms` is the 6-bit last destination bit.

A relative read of `T` or `U` never consumes the entry. `SrcL` or `SrcR` zero reads the architectural zero GPR, `RegDst` zero discards, and `immr` or `imms` zero means bit position `0`, not omission.

Design point: `immr` and `imms` are positions, not flags: `immr=0, imms=0` selects the single bit `0`, so `hl.bfi a0, a1, 0, 0, ->a2` differs from base `a0` only in that bit.

<!-- PTO-READER-BLOCK: scalar-hl-bfi-effects role=effects -->
## Effects and ordering

Both sources are read before the destination effect, because the dispatch passes both reads as arguments of the call that performs the write.

The result is published only through `RegDst`: codes `1..23` write that GPR, code `30` pushes `U`, and code `31` pushes `T`; `immr` and `imms` are never publication targets. A push makes the value the newest queue entry.

`HL.BFI` has no memory effect and changes no other architectural state. `TPC` advances by `6` bytes after the destination effect (`asl/scalar/model/dispatch/top-level.asl:55-57`).

Design point: `RegDst` may name the same GPR as `SrcL`, so the read-before-write order is observable: `hl.bfi a0, a1, 8, 15, ->a0` keeps every unselected bit of the old `a0`.

<!-- PTO-READER-BLOCK: scalar-hl-bfi-constraints role=constraints -->
## Legality and fault boundary

Every `immr` and `imms` value from `0` through `63` is assigned, so the width runs from `1` through `64`; the discard codes `0` and `24..29` are legal and write nothing.

An encoding whose fixed bits do not match the `HL48` form does not decode as `HL.BFI`, and an encoding that matches no accepted form raises `Fault_IllegalInstruction` at `PC` before any register read. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC` before the destination effect and before `TPC` advances; both sources are preflighted even when they hold the same code. An instruction not applicable to the active bundle faults with `Fault_BundleControl` at `TPC` (`asl/scalar/model/dispatch/top-level.asl:17-37`, `asl/scalar/model/types/operands.asl:6-19`).

Design point: the interval comes from two 6-bit fields and one modulo, so no operand value makes it undefined. `HL.BFI` raises no arithmetic, memory, alignment, permission, or control-flow exception.

<!-- PTO-READER-BLOCK: scalar-hl-bfi-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With the base `a0` equal to `0`, the insertion source `a1` equal to `0xff`, `immr=8`, and `imms=15`, the width is `8`: source bits `0..7` land on destination bits `8..15`, so `hl.bfi a0, a1, 8, 15, ->a2` publishes `0xff00`.

With `immr=63` and `imms=0` the width is `2`, so the metadata example `hl.bfi t#1, u#1, 63, 0, ->t` puts bit 0 of `U#1` in result bit 63, bit 1 in result bit 0, and keeps the other bits from the base `T#1`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | HL48 | 48 | 0x0000204d000e / 0xfe00707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | immr | 6 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":6}] |
| hl_bfi_48_8adfd476aacc | imms | 6 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | 0–31 | none | none | Reg5 base source | Encoded zero reads the architectural zero GPR base. |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | 0–31 | none | none | Reg5 insertion source | Encoded zero reads the architectural zero GPR insertion source. |
| hl_bfi_48_8adfd476aacc | immr | 6 | 0–63 | none | none | first destination bit | Encoded zero begins the destination interval at bit zero. |
| hl_bfi_48_8adfd476aacc | imms | 6 | 0–63 | none | none | last destination bit | Encoded zero ends the destination interval at bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 base source |
| SrcR | Reg5 insertion source |
| immr | first destination bit |
| imms | last destination bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractFirstBit_HL_BFI(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;

pure func InstructionContractLastBit_HL_BFI(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;

pure func InstructionContractResult_HL_BFI(
    base: Word,
    source: Word,
    first: integer {0..63},
    last: integer {0..63})
    => Word
begin
    return InsertBitfield(
        base,
        source,
        first,
        last);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.
- immr directly encodes the first destination bit from 0 through 63. imms directly encodes the last destination bit from 0 through 63.
- When imms precedes immr, the inclusive destination interval wraps through bit 63 to bit 0. Equal endpoints select one destination bit.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every immr and imms value is assigned. The inclusive wrapping interval has a width from 1 through 64.

## State effects

- Snapshot the base and insertion sources. Starting with source bit zero, replace ascending bits of the inclusive destination interval from immr through imms, wrapping through bit 63 when required; preserve every base bit outside that interval.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances. Both sources are preflighted even when their encoded values are equal.
- HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- hl.bfi a0, a1, 8, 15, ->a2
- hl.bfi t#1, u#1, 63, 0, ->t
- hl.bfi a0, zero, 0, 63, ->a0
