<!-- GENERATED FROM: asl/scalar/alu/BXS.asl -->
# BXS

**Normative ASL source:** `asl/scalar/alu/BXS.asl`

BXS extracts an independently selected wrapping scalar field, sign-extends it to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-BXS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bxs-purpose role=purpose -->
## What BXS does

`BXS` extracts a bit field from one Reg5 source, sign-extends it from its own most significant bit, and publishes the XLEN result through a Reg5 destination.

Design point: the field is described by two immediate values, so the extracted range is fixed by the instruction text. There is no mask register, and the source is not modified.

<!-- PTO-READER-BLOCK: scalar-bxs-mechanism role=mechanism -->
## How the result is formed

- `imms` is the field start bit `M`, from `0` through `63`.
- `imml` encodes the field width `N` minus one, so raw values `0` through `63` select widths `1` through `64`.

The `N` bits beginning at bit `M` become result bits `0` through `N-1`, and result bit `N-1` is then copied into every bit above it.

Design point: the sign bit is the last bit of the selected field, not register bit `63`. With `M=60` and `N=8` the field wraps through bit `63` to bit `0`, so the sign that decides the extension is the value of register bit `3`.

Design point: `imml` stores `N - 1` so that `N=64` is representable. With `N=64` the field is the whole register for every `M`, and sign-extending from bit `63` is the identity, so `bxs a0, 0, 64, ->a1` copies `a0`.

Design point: the extension fills bits `N` through `63` from the field sign. A caller that wants the raw field value without a sign must use `BXU`, whose only difference is that fill.

<!-- PTO-READER-BLOCK: scalar-bxs-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `imml` and `imms` describe the field and read no storage.
- `RegDst` publishes the extracted value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, so every field of it extracts to a zero result with a zero sign bit. Encoded zero of `imml` selects a `1`-bit field, whose sign bit is that single bit, so a `1`-bit field of `1` sign-extends to all ones.

<!-- PTO-READER-BLOCK: scalar-bxs-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a destination that aliases the source does not affect the extracted bits.

The result is published or discarded, and then `TPC` advances by `4` bytes. `BXS` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-bxs-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every `imml` and `imms` value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: extraction cannot fault on any source value; there is no bit pattern that is an illegal field. `BXS` reports nothing through the numeric-status state either, because an extracted sign is a result bit, not a condition.

<!-- PTO-READER-BLOCK: scalar-bxs-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=8`, `M=60` and `N=8`, the field is bits `60..63` followed by bits `0..3`. Its value is `128` and its sign bit is register bit `3`, which is set, so `bxs a0, 60, 8, ->a1` publishes `18446744073709551488`. With `SrcL=4294967295`, `M=0` and `N=64`, the published value is `4294967295` unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bxs SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | L32 | 32 | 0x00000067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxs_32_b1bb003c1703 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bxs_32_b1bb003c1703 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bxs_32_b1bb003c1703 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bxs_32_b1bb003c1703 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bxs_32_b1bb003c1703 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractOperation_BXS()
    => ScalarOperation
begin
    return ScalarOperation_BXS;
end;

pure func InstructionContractWidth_BXS(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BXS(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractHandler_BXS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;

pure func InstructionContractResult_BXS(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ExtractBitfield(
        value,
        width,
        offset,
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Sign-extend selected field bit N-1 through result bit PTO_XLEN-1.
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
- BXS raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bxs a0, 60, 8, ->a1
- bxs t#1, 0, 64, ->u
