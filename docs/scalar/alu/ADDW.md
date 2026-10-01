<!-- GENERATED FROM: asl/scalar/alu/ADDW.asl -->
# ADDW

**Normative ASL source:** `asl/scalar/alu/ADDW.asl`

ADDW applies the selected right-source transformation before its encoded logical left shift, performs fixed-width word addition, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addw-purpose role=purpose -->
## What ADDW does

`ADDW` prepares a right source exactly as `ADD` does, adds it to the left source at 32-bit width, and publishes the low `32` bits sign-extended to `PTO_XLEN`.

Design point: `ADDW` keeps the whole `ADD` field layout, including `SrcRType` and `shamt`, and changes only the width of the final addition. A program that needs both full-width and word arithmetic therefore uses two mnemonics with one operand model rather than two instruction shapes.

<!-- PTO-READER-BLOCK: scalar-addw-mechanism role=mechanism -->
## How the result is formed

The right source is prepared first, at `PTO_XLEN` width: `SrcRType` applies `00` sign-extension of `SrcR[31:0]`, `01` zero-extension of `SrcR[31:0]`, `10` negation, or `11` no change, and `shamt` then shifts that value logically left by `0` through `31` bits.

Only then are both operands truncated to their low `32` bits. `ScalarBinaryW` adds `SrcL[31:0]` and the prepared right word modulo `2^32` and sign-extends the result, so bits `63..32` of the published value are copies of result bit `31`.

Design point: the transformation and the shift run before the truncation, so `.sw`, `.uw` and `.neg` see the complete `64`-bit right source and the shifted-out bits are dropped only by the word addition.

Design point: bits `63..32` of `SrcL` are ignored, so `ADDW` is not the low half of `ADD` for large operands. `addw a0, zero, ->a0` is the canonical way to sign-extend `a0[31:0]`.

<!-- PTO-READER-BLOCK: scalar-addw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` and `SrcR` are Reg5 sources: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry.
- `SrcRType` selects the right-source transformation and `shamt` its post-transformation logical left shift. An omitted assembly suffix encodes `SrcRType=11`.
- `RegDst` publishes the sign-extended word result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero reads the architectural zero GPR for `SrcL` and `SrcR` and discards for `RegDst`; encoded zero of `SrcRType` selects `.sw`, and encoded zero of `shamt` performs no shift.

<!-- PTO-READER-BLOCK: scalar-addw-effects role=effects -->
## Effects and ordering

Both sources are read before the destination is written, so aliases between source and destination use the pre-instruction values.

The result is published or discarded, and then `TPC` advances by `4` bytes. `ADDW` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-addw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all four `SrcRType` codes and all `32` `shamt` values from `0` through `31`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: the word addition cannot fault. A sum beyond `2^32` keeps its low `32` bits and sign-extends them, so no overflow trap exists and `ADDW` needs no saturation control.

<!-- PTO-READER-BLOCK: scalar-addw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4294967295`, `SrcR=1`, `SrcRType=11` and `shamt=0`, the word sum wraps to `0` and `ADDW` publishes `0`, while `ADD` with the same operands publishes `4294967296`. With `SrcL=3` and `SrcR=3` under `SrcRType=10`, the prepared right value is `-3` and the published word is `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | L32 | 32 | 0x00000025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addw_32_a27109fe30fc | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| addw_32_a27109fe30fc | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| addw_32_a27109fe30fc | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addw_32_a27109fe30fc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| addw_32_a27109fe30fc | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| addw_32_a27109fe30fc | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| addw_32_a27109fe30fc | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| addw_32_a27109fe30fc | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractOperation_ADDW()
    => ScalarOperation
begin
    return ScalarOperation_ADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDW.asl -->
```asl
readonly func InstructionContractHandler_ADDW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ADDW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ADDW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ADDW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ADDW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ADDW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_ADD, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ADDW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_ADDW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .neg, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ADDW uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, add SrcL at 32-bit width modulo 2^32, and sign-extend the low 32-bit result to XLEN.
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

- ADDW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addw a0, a1, ->a2
- addw t#1, u#1.neg<<1, ->u
- addw zero, a0.sw, ->zero
