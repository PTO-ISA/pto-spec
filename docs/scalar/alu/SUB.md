<!-- GENERATED FROM: asl/scalar/alu/SUB.asl -->
# SUB

**Normative ASL source:** `asl/scalar/alu/SUB.asl`

SUB applies the selected right-source transformation before its encoded logical left shift, performs fixed-width subtraction, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-SUB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sub-purpose role=purpose -->
## What SUB does

`SUB` transforms the right source with `SrcRType`, shifts it logically left by `shamt`, and subtracts the result from `SrcL` modulo `2^PTO_XLEN`. It carries `RegDst`, `SrcL`, `SrcR`, `SrcRType` and `shamt`.

The carrier matches `0x00001005` under mask `0x0000707f`. The mnemonic is in the arithmetic family, so its modifier is a negation rather than a complement.

There is no encoded add/subtract mode: the mnemonic fixes the direction, and the companion `ADD` uses the same field layout.

<!-- PTO-READER-BLOCK: scalar-sub-mechanism role=mechanism -->
## How the operands are formed

Dispatch calls `ExecuteDecodedBinary` with `ScalarBinary_SUB`, `logical_family` false and `word_operation` false (`asl/scalar/model/dispatch/alu.asl:84-85`). That path reads `SrcL`, the unmodified `SrcR`, `SrcRType` and `shamt`, forms the right operand with `PrepareScalarRight(right, modifier, shift_amount, FALSE)`, and returns `left - right` from `ScalarBinary` (`asl/scalar/model/alu/semantics.asl:452`).

```asm
sub SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

- `SrcRType=00` selects `.sw`: `SignExtend{PTO_XLEN}(SrcR[31:0])`.
- `SrcRType=01` selects `.uw`: `ZeroExtend{PTO_XLEN}(SrcR[31:0])`.
- `SrcRType=10` selects `.neg`: `Zeros{PTO_XLEN} - SrcR`, the two's-complement negation of the complete register.
- `SrcRType=11` selects no modifier and leaves `SrcR` unchanged; an omitted assembly suffix encodes this value.
- `shamt` shifts the transformed value logically left by `0` through `31`.

Design point: Because `SUB` is in the arithmetic family, `SrcRType=10` negates instead of complementing. The same two-bit selector value in `OR` complements, so an encoding copied between the two mnemonics changes meaning without changing its bits.

Design point: `.neg` negates the whole `PTO_XLEN` register, while `.sw` and `.uw` first replace the upper half from bit `31`. Subtracting with `.neg` therefore differs from subtracting with `.sw` whenever the upper half of `SrcR` is not the sign extension of its low word.

<!-- PTO-READER-BLOCK: scalar-sub-inputs role=inputs-outputs -->
## Inputs and destination

Both operands are Reg5 sources, the two suffix fields are decoded from the carrier, and `RegDst` selects the destination.

- `SrcL` at `[15 +: 5]` is the minuend and `SrcR` at `[20 +: 5]` the subtrahend; both use the map `0..23` absolute GPRs, `24..27` `T#1..T#4`, `28..31` `U#1..U#4`, without consuming an entry.
- `SrcRType` at `[25 +: 2]` selects the transformation applied to `SrcR`, and `shamt` at `[27 +: 5]` the logical left shift applied afterwards.
- `RegDst` at `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, and encoded zero of `shamt` performs no shift.

Design point: The transformation and the shift are applied to `SrcR` only. `SrcL` is used unchanged, so no valid encoding lets `SUB` shift or negate the left operand; a program that needs the difference the other way round swaps the two selectors.

<!-- PTO-READER-BLOCK: scalar-sub-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the destination write, so a destination aliasing either source computes from pre-instruction values. The difference is published modulo `2^PTO_XLEN` and `TPC` advances by `4` bytes.

`SUB` reads no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state; a `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: The subtraction wraps rather than saturating, and no carry or borrow flag is recorded. `SUB` with `SrcL = 0` and `SrcR = 1` publishes the all-ones word, and a later instruction cannot tell that a borrow occurred.

<!-- PTO-READER-BLOCK: scalar-sub-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` codes and all `32` `shamt` values are assigned, as are every source and destination code of the Reg5 maps. The form has no constraint entry beyond its fixed bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `SUB` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Every check precedes the destination effect and the `TPC` advance.

Design point: The transformation, the shift and the wrapping subtraction are total, so `SUB` has no operand-selected trap. Its fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-sub-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `7` and `a1` holding `3`, `sub a0, a1, ->a2` publishes `4`, and `sub a0, a1<.neg>, ->a2` publishes `10`, because the negated subtrahend is `-3`.

With `a0` holding `0` and `a1` holding `1`, `sub a0, a1<.uw>, ->a2` publishes `0xFFFFFFFFFFFFFFFF`, the wrapped difference. With `a1` holding `1` and `shamt` equal to `4`, `sub a0, a1<<<4>, ->a2` publishes `-16`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sub SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sub_32_af383d4a2b42 | L32 | 32 | 0x00001005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sub_32_af383d4a2b42 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sub_32_af383d4a2b42 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| sub_32_af383d4a2b42 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sub_32_af383d4a2b42 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sub_32_af383d4a2b42 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| sub_32_af383d4a2b42 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| sub_32_af383d4a2b42 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| sub_32_af383d4a2b42 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUB.asl -->
```asl
readonly func InstructionContractOperation_SUB()
    => ScalarOperation
begin
    return ScalarOperation_SUB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUB.asl -->
```asl
readonly func InstructionContractHandler_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_SUB(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_SUB(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_SUB(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, FALSE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_SUB(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_SUB(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_SUB, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_SUB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsWordOperation_SUB()
    => boolean
begin
    return FALSE;
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; SUB uses .neg.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and subtract the shifted value from SrcL modulo 2^PTO_XLEN.
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

- SUB raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- sub a0, a1, ->a2
- sub t#1, u#1.neg<<1, ->u
- sub zero, a0.sw, ->zero
