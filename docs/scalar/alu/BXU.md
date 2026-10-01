<!-- GENERATED FROM: asl/scalar/alu/BXU.asl -->
# BXU

**Normative ASL source:** `asl/scalar/alu/BXU.asl`

BXU extracts an independently selected wrapping scalar field, zero-extends it to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-BXU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bxu-purpose role=purpose -->
## What BXU does

`BXU` extracts a bit field from one Reg5 source, zero-fills every bit above it, and publishes the XLEN result through a Reg5 destination.

Design point: `BXU` and `BXS` share their field syntax and their field selection exactly, and differ only in the fill of the bits above the field. A program chooses between them by what it wants to do with the extracted value, not by how it wants to slice it.

<!-- PTO-READER-BLOCK: scalar-bxu-mechanism role=mechanism -->
## How the result is formed

- `imms` is the field start bit `M`, from `0` through `63`.
- `imml` encodes the field width `N` minus one, so raw values `0` through `63` select widths `1` through `64`.

The `N` bits beginning at bit `M` become result bits `0` through `N-1`, and every bit from `N` upward is `0`.

Design point: the field wraps, so `M + N` may exceed `64` and the field continues from bit `0`; the implementation rotates the source right by `M` and reads the low `N` bits. Consequently `N=64` selects the whole register for every `M`, and `bxu a0, 60, 8, ->a1` reads bits `60..63` before bits `0..3`.

Design point: the zero fill makes the published value a pure unsigned field. It cannot exceed `2^N - 1`, so a caller that needs an unsigned small integer from a packed word does not need a second masking instruction.

<!-- PTO-READER-BLOCK: scalar-bxu-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `imml` and `imms` describe the field and read no storage.
- `RegDst` publishes the extracted value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, whose every field extracts to `0`. Encoded zero of `RegDst` discards the extracted value rather than writing it to the zero GPR, so the discard is a real choice and not a silent store.

<!-- PTO-READER-BLOCK: scalar-bxu-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a destination that aliases the source does not disturb the extracted bits.

The result is published or discarded, and then `TPC` advances by `4` bytes. `BXU` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-bxu-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every `imml` and `imms` value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: the extraction and the zero fill are total for every source value, so `BXU` has no value-dependent fault. A field that crosses a packed boundary is still just a bit range; the architecture does not interpret it.

<!-- PTO-READER-BLOCK: scalar-bxu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=18446744073709551615`, `M=0` and `N=8`, `bxu a0, 0, 8, ->a1` publishes `255`. With `SrcL=8`, `M=60` and `N=8`, the field is bits `60..63` followed by bits `0..3`; its value is `128`, so the published value is `128`, while `BXS` on the same operands publishes `18446744073709551488`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bxu SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | L32 | 32 | 0x00001067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxu_32_e9ea9715ba62 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bxu_32_e9ea9715ba62 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bxu_32_e9ea9715ba62 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bxu_32_e9ea9715ba62 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractOperation_BXU()
    => ScalarOperation
begin
    return ScalarOperation_BXU;
end;

pure func InstructionContractWidth_BXU(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BXU(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractHandler_BXU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;

pure func InstructionContractResult_BXU(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ExtractBitfield(
        value,
        width,
        offset,
        FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Zero-fill every result bit above selected field bit N-1.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or T/U destination push observes the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BXU raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bxu a0, 60, 8, ->a1
- bxu t#1, 0, 64, ->u
