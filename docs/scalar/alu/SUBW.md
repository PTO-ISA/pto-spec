<!-- GENERATED FROM: asl/scalar/alu/SUBW.asl -->
# SUBW

**Normative ASL source:** `asl/scalar/alu/SUBW.asl`

SUBW applies the selected right-source transformation before its encoded logical left shift, performs fixed-width word subtraction, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SUBW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subw-purpose role=purpose -->
## What SUBW does

`SUBW` transforms `SrcR` exactly as `SUB` does, subtracts the shifted value from the low `32` bits of `SrcL` modulo `2^32`, and publishes the word sign-extended to `PTO_XLEN`. It carries `RegDst`, `SrcL`, `SrcR`, `SrcRType` and `shamt`.

The carrier matches `0x00001025` under mask `0x0000707f`. The handler is `ScalarBinaryW` with the arithmetic-family flag, so `SrcRType=10` negates the complete right operand.

The transformation and the shift run at full width on `SrcR`; the narrowing applies to the subtraction and the publication.

<!-- PTO-READER-BLOCK: scalar-subw-mechanism role=mechanism -->
## How the word result is formed

`ExecuteDecodedBinary` reads both sources and the two suffix fields, forms the right operand with `PrepareScalarRight(right, modifier, shift_amount, FALSE)`, and with `word_operation` true calls `ScalarBinaryW(ScalarBinary_SUB, left, right)` (`asl/scalar/model/dispatch/alu.asl:86-87`). That helper computes the difference at `32` bits and returns `SignExtend{PTO_XLEN}(result32)` (`asl/scalar/model/alu/semantics.asl:477`).

```asm
subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

Design point: `.neg` negates the whole `PTO_XLEN` register before the narrowing, so the low word of the negated value is the two's-complement negation of the low word of `SrcR` whenever that low word is not zero. With a `shamt` of `31`, only the former bit `0` of the transformed value can reach word bit `31`.

Design point: The upper half of `SrcL` never enters the subtraction. `subw` with a source whose low word is zero and a right operand of `1` publishes `-1`, whatever the upper half of the source holds.

<!-- PTO-READER-BLOCK: scalar-subw-inputs role=inputs-outputs -->
## Inputs and destination

Both operands are Reg5 sources, the suffix fields come from the carrier, and `RegDst` selects the destination.

- `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming. Only the low word of each is subtracted.
- `SrcRType` at `[25 +: 2]`: `00` `.sw`, `01` `.uw`, `10` `.neg`, `11` no modifier; an omitted suffix encodes `11`.
- `shamt` at `[27 +: 5]`: the logical left shift applied to the transformed right operand, `0` through `31`.
- `RegDst` at `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.

Design point: The two width decisions are independent, so `subw` and `sub` can disagree when an operand upper half is not the sign extension of its low word. `subw` subtracts the low word of the transformed right operand and then extends the word result, while `sub` subtracts the whole transformed register.

<!-- PTO-READER-BLOCK: scalar-subw-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the write, so aliasing destinations compute from pre-instruction values. The sign-extended word is published and `TPC` advances by `4` bytes.

`SUBW` accesses no memory and leaves reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate and control-flow state unchanged; a `30` or `31` destination is the only case in which a temporary queue moves.

Design point: The word difference wraps modulo `2^32`, and the final extension reinterprets the wrapped word as a signed `32`-bit value. A borrow out of the word therefore changes the sign of the published value instead of being dropped.

<!-- PTO-READER-BLOCK: scalar-subw-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` codes and all `32` `shamt` values are assigned, as are every source and destination code of the Reg5 maps. The form carries no constraint beyond its fixed bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SUBW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: No operand value selects a trap: the modifier, the shift, the word subtraction and the sign extension are all total. The fault boundary of `SUBW` is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-subw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `7` and `a1` holding `3`, `subw a0, a1, ->a2` publishes `4`, and `subw a0, a1<.neg>, ->a2` publishes `10`.

With `a0` holding `3` and `a1` holding `7`, the word difference is `0xFFFFFFFC`, so `a2` receives `0xFFFFFFFFFFFFFFFC`. With `a1` holding `1` and `shamt` equal to `4`, `subw a0, a1<<<4>, ->a2` publishes `-13`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subw SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subw_32_3a8d45653c98 | L32 | 32 | 0x00001025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subw_32_3a8d45653c98 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| subw_32_3a8d45653c98 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| subw_32_3a8d45653c98 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subw_32_3a8d45653c98 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| subw_32_3a8d45653c98 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| subw_32_3a8d45653c98 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| subw_32_3a8d45653c98 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| subw_32_3a8d45653c98 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractOperation_SUBW()
    => ScalarOperation
begin
    return ScalarOperation_SUBW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBW.asl -->
```asl
readonly func InstructionContractHandler_SUBW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_SUBW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_SUBW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_SUBW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_SUBW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_SUBW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_SUB, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_SUBW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_SUBW()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; SUBW uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, subtract SrcL at 32-bit width modulo 2^32, and sign-extend the low 32-bit result to XLEN.
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

- SUBW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subw a0, a1, ->a2
- subw t#1, u#1.neg<<1, ->u
- subw zero, a0.sw, ->zero
