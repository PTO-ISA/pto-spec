<!-- GENERATED FROM: asl/scalar/alu/BCNT.asl -->
# BCNT

**Normative ASL source:** `asl/scalar/alu/BCNT.asl`

BCNT counts set bits in an independently selected wrapping scalar field and publishes the XLEN population count.

## Normative identity {#PTO-INST-SCALAR-BCNT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bcnt-purpose role=purpose -->
## What BCNT does

`BCNT` selects a bit field inside one Reg5 source, counts how many of its bits are set, and publishes that count as an XLEN word through a Reg5 destination.

Design point: `BCNT` takes its field from two immediate fields instead of from a mask register. That keeps the operation to three encoded operands and makes the selected field a property of the instruction text rather than of run-time state.

<!-- PTO-READER-BLOCK: scalar-bcnt-mechanism role=mechanism -->
## How the result is formed

- `imms` is the field start bit `M`, from `0` through `63`.
- `imml` encodes the field width `N` minus one, so raw values `0` through `63` select widths `1` through `64`.

The instruction extracts the `N`-bit field beginning at bit `M` and counts the set bits in it. The published value is the count, so an all-zero field publishes `0` and an all-ones field publishes `N`.

Design point: `imml` stores `N - 1` rather than `N` so that `N=64`, the complete register, still fits in six bits. Encoded zero therefore selects a one-bit field, not an empty or omitted field.

Design point: the field wraps. When `M + N` exceeds `64`, the field continues from bit `0`; the implementation rotates the source right by `M` and then reads the low `N` bits. A consequence a programmer can rely on is that `N=64` selects the whole register for every `M`, so `bcnt a0, 0, 64, ->a1` and `bcnt a0, 63, 64, ->a1` publish the same count.

Design point: the width is a 6-bit immediate, so the selected field can never exceed `64` bits and the count can never exceed `64`. No saturation rule is needed, and no overflow can occur.

<!-- PTO-READER-BLOCK: scalar-bcnt-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `imml` and `imms` are encoded fields, not registers, so they name no storage.
- `RegDst` publishes the count: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, whose every bit field counts to `0`. Encoded zero of `imml` selects a `1`-bit field and encoded zero of `imms` starts it at bit `0`, so `bcnt zero, 0, 1, ->a1` publishes `0` with no source read that can change the answer.

<!-- PTO-READER-BLOCK: scalar-bcnt-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a destination that aliases the source does not change the counted value.

The count is published or discarded, and then `TPC` advances by `4` bytes. `BCNT` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-bcnt-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every `imml` and `imms` value. There is no reserved field width and no reserved start bit.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: counting bits produces no exceptional value, so `BCNT` raises no arithmetic, memory, alignment or permission fault. Its fault boundary is entirely encoding and source availability.

<!-- PTO-READER-BLOCK: scalar-bcnt-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=1`, `M=60` and `N=8`, the selected field is bits `60..63` followed by bits `0..3`; it contains the set bit `0`, so `bcnt a0, 60, 8, ->a1` publishes `1`. With `SrcL=18446744073709551615`, `M=0` and `N=64`, every selected bit is set and the published count is `64`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bcnt srcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | L32 | 32 | 0x00006067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bcnt_32_e0b06e436a5b | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bcnt_32_e0b06e436a5b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bcnt_32_e0b06e436a5b | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bcnt_32_e0b06e436a5b | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractOperation_BCNT()
    => ScalarOperation
begin
    return ScalarOperation_BCNT;
end;

pure func InstructionContractWidth_BCNT(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BCNT(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractHandler_BCNT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_BCNT(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        FALSE,
        TRUE);
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count every set bit in the selected field. An all-zero selected field returns zero and an all-one selected field returns N.
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
- BCNT raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bcnt a0, 0, 64, ->a1
- bcnt t#1, 60, 8, ->u
- bcnt zero, 0, 1, ->zero
