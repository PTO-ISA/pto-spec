<!-- GENERATED FROM: asl/scalar/alu/XORW.asl -->
# XORW

**Normative ASL source:** `asl/scalar/alu/XORW.asl`

XORW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise exclusive OR, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-XORW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xorw-purpose role=purpose -->
## What XORW computes

`XORW` is the word form of the register exclusive OR. It prepares `SrcR` with the selected transformation and shift, keeps only the low 32 bits of that prepared value and of `SrcL`, exclusive-ORs them, sign-extends the result to `PTO_XLEN`, and publishes it through `RegDst`.

Two things therefore differ from `XOR`: the operands are narrowed to their low words, and the published value is the sign-extended word. `XORW` advances `TPC` by `4` bytes, reads no memory and raises no arithmetic exception.

Design point: the prepared value stays 64 bits wide, but the two extension modifiers cannot change the outcome. `.sw` and `.uw` rewrite only bits above bit 31, the word window discards exactly those bits, and a left shift never moves a bit downward. `xorw a0, a1.sw, ->a2` and `xorw a0, a1.uw, ->a2` therefore publish the same value as `xorw a0, a1, ->a2`; only `.not` changes it.

<!-- PTO-READER-BLOCK: scalar-xorw-mechanism role=mechanism -->
## Preparing the right source, then narrowing to a word

Execution reads `SrcL` and `SrcR`, transforms `SrcR` as `SrcRType` selects, shifts the result left by `shamt`, then takes the low 32 bits of that prepared value and exclusive-ORs them with the low 32 bits of `SrcL`. The 32-bit result is sign-extended before publication.

The four `SrcRType` encodings have the same meaning as for `XOR`:

- `00` (`.sw`) sign-extends `SrcR[31:0]` to `PTO_XLEN`.
- `01` (`.uw`) zero-extends `SrcR[31:0]` to `PTO_XLEN`.
- `10` (`.not`) complements all `PTO_XLEN` bits.
- `11` (omitted suffix) leaves `SrcR` unchanged.

Design point: `.not` complements all 64 bits, and the low word of that complement enters the operation: with `SrcR=0x0000000000000001` the prepared value is `0xfffffffffffffffe` and the window holds `0xfffffffe`.

Design point: the shift runs before the narrowing, so a low-word bit shifted past bit 31 leaves the result. With `SrcR=0x0000000080000000` and `shamt=1` the window holds `0x00000000`, and that zero reaches the exclusive OR.

Design point: bit 31 of the word exclusive OR decides the upper half of the published value, so `XORW` can publish `0xffffffff80000000` from a source whose low word is `0x80000000`.

<!-- PTO-READER-BLOCK: scalar-xorw-inputs role=inputs-outputs -->
## Encoded operands

- `RegDst` is a 5-bit field at instruction bits `7..11`: codes `1..23` write that absolute GPR, code `0` and codes `24..29` discard, code `30` pushes the U queue and code `31` pushes the T queue.
- `SrcL` is a 5-bit field at bits `15..19` and `SrcR` at bits `20..24`. Codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4` and `28..31` read `U#1..U#4`.
- `SrcRType` is a 2-bit field at bits `25..26`; `shamt` is a 5-bit field at bits `27..31`.

A queue source is read without being consumed and source code `0` reads zero. `XORW` has no address operand, no ordering bit and no `far` field.

<!-- PTO-READER-BLOCK: scalar-xorw-effects role=effects -->
## Destination and ordering

Both sources are read before the destination is written, and the published value is computed from those pre-instruction values.

Design point: `xorw a0, a1, ->a0` publishes the word exclusive OR of the old `a0` with the prepared `a1`, and `xorw a0, a0, ->a1` publishes `0x0` whatever `a0` held. The narrowing happens inside the operation, so the discarded upper halves never affect the result.

A successful execution advances `TPC` by `4` bytes. No memory location, reservation, descriptor, numeric flag, trap, block, privilege or control-flow state changes.

<!-- PTO-READER-BLOCK: scalar-xorw-constraints role=constraints -->
## Legality and the fault boundary

Every `SrcRType` encoding and every `shamt` value from `0` through `31` is assigned, and so is every source and destination code, so `XORW` has no reserved field value. Word exclusive OR and the final sign extension are total, so no arithmetic exception is raised.

Before any effect the form is decoded, its encoded fields are checked, and each selected T/U source must hold a valid queue entry. An encoding owned by no form, or an unavailable `T#1..T#4` or `U#1..U#4` entry, raises `Fault_IllegalInstruction` before the destination write and before `TPC` advances.

Design point: `XORW` forms no address, so it can raise neither an alignment fault nor an access fault. After a successful decode, applicability is checked first: while the system-block terminal marker `_SystemBlockTerminalPending` is set, that check rejects any scalar operation with `Fault_BundleControl`. Apart from that, the remaining reason to reject `XORW` is operand availability, and the truncation to 32 bits is not a fault condition.

<!-- PTO-READER-BLOCK: scalar-xorw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=0x0000000000000000`, `SrcR=0x0000000080000000`, `SrcRType=11` and `shamt=0`, the prepared right source is `0x0000000080000000`, its low word `0x80000000` is exclusive-ORed with the low word of `SrcL`, and the published value is `0xffffffff80000000`.

With the same operands but `shamt=1`, the prepared value is `0x0000000100000000`, the window holds `0x00000000`, and the published value is `0x0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xorw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | L32 | 32 | 0x00004025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xorw_32_32282566e32d | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xorw_32_32282566e32d | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| xorw_32_32282566e32d | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| xorw_32_32282566e32d | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| xorw_32_32282566e32d | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| xorw_32_32282566e32d | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractOperation_XORW()
    => ScalarOperation
begin
    return ScalarOperation_XORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractHandler_XORW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_XORW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_XORW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_XORW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_XORW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_XORW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_XOR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_XORW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; XORW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise exclusive OR with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
- Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- XORW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xorw a0, a1, ->a2
- xorw t#1, u#1.not<<1, ->u
- xorw zero, a0.sw, ->zero
