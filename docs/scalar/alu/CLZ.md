<!-- GENERATED FROM: asl/scalar/alu/CLZ.asl -->
# CLZ

**Normative ASL source:** `asl/scalar/alu/CLZ.asl`

CLZ counts leading zero bits in an independently selected wrapping scalar field and publishes the XLEN count.

## Normative identity {#PTO-INST-SCALAR-CLZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-clz-purpose role=purpose -->
## What CLZ does

`CLZ` counts the zero bits that precede the first one bit at the most significant end of a selected field of one Reg5 source, and publishes that count as an XLEN value.

Design point: the counted domain is chosen by two independent encoded fields instead of being the whole register. `imms` gives the first bit of the field and `imml` gives its width, so one instruction can count a byte, a word, or all sixty-four bits.

<!-- PTO-READER-BLOCK: scalar-clz-mechanism role=mechanism -->
## How the result is formed

The field is extracted by rotating the source right by the start bit and taking the low `N` bits, so field bit zero is source bit `M`, and a field may run past bit `63` and continue from bit `0`. The count then walks down from the field's own most significant bit and stops at the first one bit. A field that is entirely zero returns `N`.

Design point: `imml` stores `N` minus one, so encoded zero selects a one-bit field rather than a zero-width field. Every six-bit value then names a usable count domain from `1` through `64`, and the widest field is the encoded value `63`.

Design point: the published count saturates at the selected width, not at `PTO_XLEN`. Counting an all-zero eight-bit field publishes `8`, so the answer is always expressed in the coordinate system of the field the caller chose.

<!-- PTO-READER-BLOCK: scalar-clz-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is a Reg5 source: codes `0..23` select absolute GPRs, `24..27` select `T#1..T#4`, and `28..31` select `U#1..U#4`, read without consuming a queue entry.
- `imms` is the start bit `M`, directly encoded from `0` through `63`.
- `imml` is the width `N` minus one, encoded from `0` through `63`, giving `N` from `1` through `64`.
- `RegDst` publishes through the common destination map: codes `0` and `24..29` discard, `1..23` write a GPR, `30` pushes `U`, and `31` pushes `T`.

Design point: encoded zero has a defined meaning in all four fields, so `clz zero, 0, 1, ->zero` is a complete instruction: it counts the single bit zero of the architectural zero GPR and discards the result.

<!-- PTO-READER-BLOCK: scalar-clz-effects role=effects -->
## Effects and ordering

`SrcL` is snapshotted before any destination effect, so a GPR destination that aliases the source, or a destination push into the same queue, observes the pre-instruction source value. The count is then published as one XLEN value.

After publication, `TPC` advances by `4` bytes. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target or other control state changes; a relative source is non-consuming, and only a `T` or `U` destination push changes a temporary queue.

<!-- PTO-READER-BLOCK: scalar-clz-constraints role=constraints -->
## Legality and fault boundary

Every `imml` and `imms` value is assigned, so all widths from `1` through `64` and all start bits from `0` through `63` are legal, and no field value is reserved. The fixed encoding bits must match the canonical form.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. `CLZ` raises no arithmetic, memory, alignment, permission or control-flow exception for any operand.

Design point: the discard destinations are legal and do not skip the source check. A discard form whose source is available reads and preflights `SrcL`, then changes no architectural state except `TPC`, which is what makes it usable as a defined placeholder.

<!-- PTO-READER-BLOCK: scalar-clz-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `256`, `clz a0, 0, 64, ->a1` counts the whole register and pushes `55`, because bit `8` is the highest set bit. With `T#1` holding `2^63`, `clz t#1, 62, 4, ->a0` selects the four bits `62`, `63`, `0`, `1` and scans them in the order `1`, `0`, `63`, `62`, so it counts the two zeros at bits `1` and `0` and pushes `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
clz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | L32 | 32 | 0x00005067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| clz_32_f890415c15b6 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| clz_32_f890415c15b6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| clz_32_f890415c15b6 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| clz_32_f890415c15b6 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| clz_32_f890415c15b6 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractOperation_CLZ()
    => ScalarOperation
begin
    return ScalarOperation_CLZ;
end;

pure func InstructionContractWidth_CLZ(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_CLZ(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractHandler_CLZ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_CLZ(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        TRUE,
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count zero bits from the selected field most-significant end until the first one. An all-zero selected field returns N.
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
- CLZ raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- clz a0, 0, 64, ->a1
- clz t#1, 60, 8, ->u
- clz zero, 0, 1, ->zero
