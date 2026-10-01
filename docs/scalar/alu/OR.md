<!-- GENERATED FROM: asl/scalar/alu/OR.asl -->
# OR

**Normative ASL source:** `asl/scalar/alu/OR.asl`

OR applies the selected right-source transformation before its encoded logical left shift, performs bitwise inclusive OR, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-or-purpose role=purpose -->
## What OR does

`OR` forms a right operand from `SrcR` and publishes the bitwise inclusive OR of that operand with `SrcL` at the full `PTO_XLEN` width. It carries five fields: `RegDst`, `SrcL`, `SrcR`, the two-bit `SrcRType` selector and the five-bit `shamt`.

The carrier matches `0x00003005` under mask `0x0000707f`; the mnemonic and those five fields fix everything the instruction does.

`OR` is in the logical family, and that family flag is what makes `SrcRType=10` a ones complement rather than a negation.

<!-- PTO-READER-BLOCK: scalar-or-mechanism role=mechanism -->
## How the operands are formed

Dispatch reads `SrcL`, the unmodified `SrcR`, `SrcRType` and `shamt`, then calls `PrepareScalarRight(unmodified_right, modifier, shift_amount, TRUE)` at `asl/scalar/model/dispatch/alu.asl:80-83`. That helper applies the modifier first and then shifts the result logically left by `shamt`; the modified and shifted value is the right operand of the final `ScalarBinary_OR`.

```asm
or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

- `SrcRType=00` selects `.sw`: `SignExtend{PTO_XLEN}(SrcR[31:0])`.
- `SrcRType=01` selects `.uw`: `ZeroExtend{PTO_XLEN}(SrcR[31:0])`.
- `SrcRType=10` selects `.not`: every bit of the complete `SrcR` is complemented.
- `SrcRType=11` selects no modifier and leaves `SrcR` unchanged; an omitted assembly suffix encodes this value.
- `shamt` shifts the transformed value logically left by `0` through `31`; an encoded zero performs no shift.

Design point: `.not` complements all `PTO_XLEN` bits of `SrcR`, not only the low word, so `or a0, a1<.not>, ->a2` is the way to OR in the complement of a full register. `.sw` and `.uw` replace the upper bits first, so following either of them with `.not` is not expressible in one instruction.

Design point: The transformation applies to `SrcR` only. `SrcL` reaches the disjunction untouched.

<!-- PTO-READER-BLOCK: scalar-or-inputs role=inputs-outputs -->
## Inputs and destination

`SrcL` and `SrcR` are five-bit Reg5 fields; `SrcRType` and `shamt` are encoded selectors inside the carrier; `RegDst` is the five-bit destination.

- `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]` read the Reg5 map: `0..23` absolute GPRs, `24..27` `T#1..T#4`, `28..31` `U#1..U#4`, never consuming an entry.
- `SrcRType` at `[25 +: 2]` selects the right-source transformation, and `shamt` at `[27 +: 5]` selects the post-transformation logical left shift.
- `RegDst` at `[7 +: 5]` publishes the OR: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.
- Encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, and encoded zero of `shamt` shifts by nothing.

Design point: Encoded zero of `SrcRType` selects `.sw`, not no modifier. The unmodified right operand is the value `11`, so an assembler that omits the suffix and an assembler that writes `.sw` produce different instructions.

<!-- PTO-READER-BLOCK: scalar-or-effects role=effects -->
## Effects and ordering

Both sources are read before the destination write, so a destination that aliases `SrcL` or `SrcR` still ORs the pre-instruction values. The result is published, and then `TPC` advances by `4` bytes.

`OR` touches no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state. The only queue movement it can cause is the single push selected by a `30` or `31` destination.

Design point: Reading `SrcR` before the modifier runs means a `30` or `31` destination cannot feed the modified value back into the same instruction, even though the push renames that queue slot. A later instruction reads the pushed result as `T#1` or `U#1`.

<!-- PTO-READER-BLOCK: scalar-or-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` codes, all `32` `shamt` values from `0` through `31`, all `32` source codes and all `32` destination codes are assigned. The form has no constraint entry beyond its fixed encoding bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; for `OR` that is reachable only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`, before the destination effect and before `TPC` advances.

Design point: `OR` is total over all operand values: no selector combination and no source bit pattern produces a trap, so the fault boundary is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-or-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `0x0F0F` and `a1` holding `0x00F0`, `or a0, a1, ->a2` publishes `0x0FFF`.

With `a0` holding `0` and `a1` holding `1`, `or a0, a1<.sw><<<4>, ->a2` first sign-extends the low word `1` and then shifts it left by `4`, so `a2` receives `16`. The same encoding with `SrcRType=10` complements `a1` instead, and shifting that complement left by `4` publishes `0xFFFFFFFFFFFFFFE0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| or_32_a7fb80e78831 | L32 | 32 | 0x00003005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| or_32_a7fb80e78831 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| or_32_a7fb80e78831 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| or_32_a7fb80e78831 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| or_32_a7fb80e78831 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| or_32_a7fb80e78831 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| or_32_a7fb80e78831 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| or_32_a7fb80e78831 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| or_32_a7fb80e78831 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/OR.asl -->
```asl
readonly func InstructionContractOperation_OR()
    => ScalarOperation
begin
    return ScalarOperation_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/OR.asl -->
```asl
readonly func InstructionContractHandler_OR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_OR(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_OR(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_OR(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_OR(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_OR(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_OR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_OR()
    => boolean
begin
    return FALSE;
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; OR uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the bitwise inclusive OR with SrcL at PTO_XLEN width modulo 2^PTO_XLEN.
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

- OR raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- or a0, a1, ->a2
- or t#1, u#1.not<<1, ->u
- or zero, a0.sw, ->zero
