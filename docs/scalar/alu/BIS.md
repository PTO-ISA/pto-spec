<!-- GENERATED FROM: asl/scalar/alu/BIS.asl -->
# BIS

**Normative ASL source:** `asl/scalar/alu/BIS.asl`

BIS sets every bit in an independently selected wrapping scalar field and publishes the modified XLEN value.

## Normative identity {#PTO-INST-SCALAR-BIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bis-purpose role=purpose -->
## What BIS does

`BIS` sets every bit of a selected bit field inside one Reg5 source and publishes the modified XLEN value through a Reg5 destination.

Design point: `BIS` is the exact complement of `BIC`: both take the field from the same two immediate fields and both preserve everything outside it, and only the value written into the field differs. The pair therefore covers field-scoped set and clear without a mask operand.

<!-- PTO-READER-BLOCK: scalar-bis-mechanism role=mechanism -->
## How the result is formed

- `imms` is the field start bit `M`, from `0` through `63`.
- `imml` encodes the field width `N` minus one, so raw values `0` through `63` select widths `1` through `64`.

The `N` bits beginning at bit `M` are written as `1`. Every bit outside the selected field keeps the value it had in the source.

Design point: `imml` stores `N - 1` so that a `64`-bit field fits in six bits. Encoded zero therefore sets one bit rather than doing nothing, which is why `bis a0, 0, 1, ->a1` is a defined single-bit set operation.

Design point: the field wraps when `M + N` exceeds `64`; the implementation rotates the source, writes the low `N` bits, and rotates back. As a result `N=64` sets every bit for every `M`, and `bis a0, 63, 2, ->a1` sets bits `63` and `0`.

<!-- PTO-READER-BLOCK: scalar-bis-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `imml` and `imms` describe the field and read no storage.
- `RegDst` publishes the modified value: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` reads the architectural zero GPR, and a set of any field of it publishes exactly the selected bits. Encoded zero of `RegDst` discards the result instead of writing it to the zero GPR, so the discarded encoding is not a way to set bits in place.

<!-- PTO-READER-BLOCK: scalar-bis-effects role=effects -->
## Effects and ordering

`SrcL` is read before the destination is written, so a destination that aliases the source still uses the pre-instruction value as its base.

The result is published or discarded, and then `TPC` advances by `4` bytes. `BIS` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-bis-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all `32` `SrcL` codes, all `32` `RegDst` codes, and every `imml` and `imms` value.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: setting bits cannot produce an exceptional value, so `BIS` has no value-dependent fault. A field that overlaps bits another part of the program owns is a programming error, and the architecture reports nothing.

<!-- PTO-READER-BLOCK: scalar-bis-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=0`, `M=4` and `N=4`, `bis a0, 4, 4, ->a1` publishes `240`, the sum of bits `4`, `5`, `6` and `7`. With `SrcL=4095` and `M=0`, `N=64`, the published value is `18446744073709551615`, because the whole register is selected.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bis SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bis_32_bca5d1a80f32 | L32 | 32 | 0x00003067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bis_32_bca5d1a80f32 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bis_32_bca5d1a80f32 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bis_32_bca5d1a80f32 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bis_32_bca5d1a80f32 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bis_32_bca5d1a80f32 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bis_32_bca5d1a80f32 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bis_32_bca5d1a80f32 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bis_32_bca5d1a80f32 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractOperation_BIS()
    => ScalarOperation
begin
    return ScalarOperation_BIS;
end;

pure func InstructionContractWidth_BIS(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BIS(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BIS.asl -->
```asl
readonly func InstructionContractHandler_BIS()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;

pure func InstructionContractResult_BIS(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ModifyBitfield(
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Set the N selected source bits and preserve every unselected source bit.
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
- BIS raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bis a0, 60, 8, ->a1
- bis t#1, 0, 64, ->u
