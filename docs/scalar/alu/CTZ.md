<!-- GENERATED FROM: asl/scalar/alu/CTZ.asl -->
# CTZ

**Normative ASL source:** `asl/scalar/alu/CTZ.asl`

CTZ counts trailing zero bits in an independently selected wrapping scalar field and publishes the XLEN count.

## Normative identity {#PTO-INST-SCALAR-CTZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ctz-purpose role=purpose -->
## What CTZ does

`CTZ` counts the zero bits that follow the first one bit at the least significant end of a selected field of one Reg5 source, and publishes that count as an XLEN value. An all-zero field has no one bit, and the published count is then the field width.

Design point: `CTZ` and `CLZ` encode the same two field parameters and select the same bits; only the direction of the scan differs. A caller that wants both ends of one window writes both mnemonics with identical `M` and `N`.

<!-- PTO-READER-BLOCK: scalar-ctz-mechanism role=mechanism -->
## How the result is formed

The source is rotated right by the start bit `M` and the low `N` bits become the field, so the field wraps past bit `63` to bit `0` when it crosses the top of the register. The count starts at field bit zero and walks upward, adding one for each zero until a one bit stops it.

Design point: the callback into the shared counting helper differs from the `CLZ` callback only in its direction flag, while both mnemonics pass the same width and start parameters. There is therefore no separate encoding of "count from the other end"; the mnemonic chooses it.

Design point: because the scan walks upward and the field may wrap, a field that starts near the top of the register is traversed as source bit `M`, `M+1`, and so on, continuing at source bit `0`. The count is expressed in that wrapped order, not in ascending source-bit order from bit zero.

<!-- PTO-READER-BLOCK: scalar-ctz-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` selects the Reg5 source: absolute GPRs for codes `0..23`, `T#1..T#4` for `24..27`, and `U#1..U#4` for `28..31`, read without consuming a queue entry.
- `imms` directly encodes the field start bit `M` from `0` through `63`; encoded zero starts at source bit zero.
- `imml` encodes the field width `N` minus one from `0` through `63`; encoded zero selects a width of one bit.
- `RegDst` is the destination or discard selector: `0` and `24..29` discard, `1..23` write a GPR, `30` pushes `U`, `31` pushes `T`.

Design point: the count is published as a complete XLEN value even though it can never exceed `64`, so the two fields of the encoding never interact with the result width. A one-bit field therefore publishes `0` or `1` and nothing else.

<!-- PTO-READER-BLOCK: scalar-ctz-effects role=effects -->
## Effects and ordering

The source is read and snapshotted before the destination effect, so `ctz a0, 0, 64, ->a0` counts the old `a0` rather than the value it is about to write. The XLEN count is published through `RegDst`, and only a `T` or `U` destination push moves a temporary queue.

`TPC` advances by `4` bytes after publication. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target or other control state changes.

<!-- PTO-READER-BLOCK: scalar-ctz-constraints role=constraints -->
## Legality and fault boundary

Every `imml` and `imms` value is assigned: widths `1` through `64` and start bits `0` through `63` are all legal, and the fixed encoding bits must match the canonical form. No operand value of `CTZ` is reserved or unassigned.

An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances. `CTZ` raises no arithmetic, memory, alignment, permission or control-flow exception for any field selection.

Design point: a source that is not available is rejected even though the instruction only reads it. The rejection happens before the destination effect, so a faulting `CTZ` leaves the source, the queues and `TPC` exactly as they were.

<!-- PTO-READER-BLOCK: scalar-ctz-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `256`, `ctz a0, 0, 64, ->a1` pushes `8`, because bits `0` through `7` are zero and bit `8` is the first one bit. With `T#1` holding `2^63`, `ctz t#1, 62, 4, ->a0` builds the field from source bits `62`, `63`, `0`, `1` in that ascending order and pushes `1`, because the first field bit is source bit `62`, which is zero, and the next field bit is source bit `63`, which is the first one bit.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ctz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | L32 | 32 | 0x00004067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| ctz_32_1761cbcc2a89 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ctz_32_1761cbcc2a89 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| ctz_32_1761cbcc2a89 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| ctz_32_1761cbcc2a89 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| ctz_32_1761cbcc2a89 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractOperation_CTZ()
    => ScalarOperation
begin
    return ScalarOperation_CTZ;
end;

pure func InstructionContractWidth_CTZ(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_CTZ(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractHandler_CTZ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_CTZ(
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count zero bits from selected field bit zero until the first one. An all-zero selected field returns N.
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
- CTZ raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- ctz a0, 0, 64, ->a1
- ctz u#1, 60, 8, ->t
- ctz zero, 0, 1, ->zero
