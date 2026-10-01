<!-- GENERATED FROM: asl/scalar/alu/ANDW.asl -->
# ANDW

**Normative ASL source:** `asl/scalar/alu/ANDW.asl`

ANDW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise conjunction, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ANDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andw-purpose role=purpose -->
## What ANDW does

`ANDW` prepares a right source as `AND` does, computes the conjunction over the low `32` bits, and publishes that word sign-extended to `PTO_XLEN`.

Design point: `ANDW` and `AND` share all five fields, so a program can switch between full-width and word masking without changing its operand layout. Only the width of the conjunction and of the publication differ.

<!-- PTO-READER-BLOCK: scalar-andw-mechanism role=mechanism -->
## How the result is formed

`SrcRType` transforms the complete `SrcR` value: `00` sign-extends `SrcR[31:0]`, `01` zero-extends `SrcR[31:0]`, `10` complements every bit, and `11` leaves it unchanged. `shamt` then shifts the transformed value logically left by `0` through `31` bits.

The conjunction is taken on the low `32` bits of both operands, and result bit `31` is copied into bits `63..32` of the published value.

Design point: because the family flag marks `ANDW` as logical, `SrcRType=10` is a complement here, while the same code in `ADDW` is a negation. The two mnemonics differ in that one behaviour as well as in the operation itself.

Design point: bits `63..32` of `SrcL` are excluded before the conjunction, so a source whose upper word is set cannot keep those bits in the result.

<!-- PTO-READER-BLOCK: scalar-andw-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` and `SrcR` are Reg5 sources: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`, without consuming a queue entry.
- `SrcRType` selects the right-source transformation and `shamt` its post-transformation logical left shift. An omitted assembly suffix encodes `SrcRType=11`.
- `RegDst` publishes the sign-extended word result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero reads the architectural zero GPR for both sources and discards for the destination; encoded zero of `SrcRType` selects `.sw`, so the modifier must be encoded explicitly when `.not` is wanted.

<!-- PTO-READER-BLOCK: scalar-andw-effects role=effects -->
## Effects and ordering

Both sources are read before the destination is written, so an alias between source and destination observes the pre-instruction value.

The result is published or discarded, and then `TPC` advances by `4` bytes. `ANDW` accesses no memory and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-andw-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all four `SrcRType` codes and all `32` `shamt` values from `0` through `31`.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: neither the truncation to `32` bits nor the final sign extension can fault, so `ANDW` has no value-dependent trap. Its whole fault boundary is encoding and source availability.

<!-- PTO-READER-BLOCK: scalar-andw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=4294967295`, `SrcR=15`, `SrcRType=11` and `shamt=0`, `ANDW` publishes `15`. With `SrcL=18446744073709551615` and `SrcR=3`, the published value is `3`, because only the low word of the source takes part in the conjunction.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andw_32_6907ed7cec90 | L32 | 32 | 0x00002025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andw_32_6907ed7cec90 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| andw_32_6907ed7cec90 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| andw_32_6907ed7cec90 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andw_32_6907ed7cec90 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| andw_32_6907ed7cec90 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| andw_32_6907ed7cec90 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| andw_32_6907ed7cec90 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| andw_32_6907ed7cec90 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDW.asl -->
```asl
readonly func InstructionContractOperation_ANDW()
    => ScalarOperation
begin
    return ScalarOperation_ANDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDW.asl -->
```asl
readonly func InstructionContractHandler_ANDW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ANDW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ANDW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ANDW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ANDW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ANDW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_AND, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ANDW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDW()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ANDW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise conjunction with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
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

- ANDW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andw a0, a1, ->a2
- andw t#1, u#1.not<<1, ->u
- andw zero, a0.sw, ->zero
