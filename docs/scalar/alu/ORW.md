<!-- GENERATED FROM: asl/scalar/alu/ORW.asl -->
# ORW

**Normative ASL source:** `asl/scalar/alu/ORW.asl`

ORW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise inclusive OR, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-ORW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-orw-purpose role=purpose -->
## What ORW does

`ORW` prepares `SrcR` exactly as `OR` does, ORs it with the low `32` bits of `SrcL` at `32`-bit width, and publishes the word sign-extended to `PTO_XLEN`. It carries `RegDst`, `SrcL`, `SrcR`, `SrcRType` and `shamt`.

The carrier matches `0x00003025` under mask `0x0000707f` and dispatches `ScalarBinaryW` with the logical-family flag set, so `SrcRType=10` complements the complete right operand.

Only the low word of each side reaches the disjunction, but the modifier and the shift act on the whole `PTO_XLEN` right operand first.

<!-- PTO-READER-BLOCK: scalar-orw-mechanism role=mechanism -->
## How the word result is formed

`ExecuteDecodedBinary` reads `SrcL`, the unmodified `SrcR`, `SrcRType` and `shamt`, then forms the right operand with `PrepareScalarRight(right, modifier, shift_amount, TRUE)`. With `word_operation` true it calls `ScalarBinaryW(ScalarBinary_OR, left, right)`, whose `left32`/`right32` bindings keep `[31:0]` and whose return is `SignExtend{PTO_XLEN}` of the `32`-bit OR (`asl/scalar/model/dispatch/alu.asl:82-83`, `asl/scalar/model/alu/semantics.asl:470-487`).

```asm
orw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

Design point: The shift happens before the narrowing, so `shamt` can carry bits of `SrcR` into the low word from below bit `32` but never from above it. Shifting a `.sw` or `.uw` right operand by `31` places its former bit `0` into word bit `31`, which then becomes a sign bit of the published word.

Design point: Because the narrowing happens last, the upper word of `SrcL` cannot set any result bit. `orw` with `SrcL` holding an all-ones upper half still publishes only what the low words produce.

<!-- PTO-READER-BLOCK: scalar-orw-inputs role=inputs-outputs -->
## Inputs and destination

Both sources use the Reg5 source map, the suffix fields are decoded from the carrier, and the result leaves through the Reg5 destination map.

- `SrcL` at `[15 +: 5]` and `SrcR` at `[20 +: 5]`: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, `28..31` read `U#1..U#4`, non-consuming.
- `SrcRType` at `[25 +: 2]`: `00` `.sw`, `01` `.uw`, `10` `.not`, `11` no modifier; an omitted suffix encodes `11`.
- `shamt` at `[27 +: 5]`: the logical left shift applied after the modifier, `0` through `31`.
- `RegDst` at `[7 +: 5]`: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` with `24..29` discard.

Design point: `.not` complements `PTO_XLEN` bits of `SrcR`, so `orw a0, a1<.not>, ->a2` publishes the OR of the low word of `a0` with the complement of the low word of `a1`. The modifier and the narrowing are independent: the complement is never restricted to `32` bits.

<!-- PTO-READER-BLOCK: scalar-orw-effects role=effects -->
## Effects and ordering

Both sources are snapshotted before the write, so destination aliases observe pre-instruction values. The word is published and `TPC` advances by `4` bytes.

`ORW` touches no memory and changes no reservation, descriptor, numeric-flag, trap, bundle, privilege, predicate or control-flow state. A `30` or `31` destination is the only case in which it moves a temporary queue.

Design point: The published word always has a defined upper half: bits `63..32` repeat bit `31` of the OR. A consumer that needs a zero-extended word has to clear those bits itself, because `ORW` offers no zero-extending variant.

<!-- PTO-READER-BLOCK: scalar-orw-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` codes and all `32` `shamt` values are assigned, as are every source and destination code of the Reg5 maps. The form carries no constraint beyond its fixed bits.

An unmatched carrier raises `Fault_IllegalInstruction` at `PC`. An instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`, reachable for `ORW` only while a system-block terminal request is pending. An unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` at `PC`. Each check precedes the destination effect and the `TPC` advance.

Design point: No operand value selects a trap: the transformation, the shift, the word OR and the sign extension are all total. The fault boundary of `ORW` is encoding validity plus source availability.

<!-- PTO-READER-BLOCK: scalar-orw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` whose low `32` bits are `0x00F0` and `a1` holding `0x000000000000000F`, `orw a0, a1, ->a2` publishes `0x00FF`.

With `a0` holding `1` and `a1` holding `1`, `orw a0, a1<.sw><<<31>, ->a2` shifts the transformed `1` left by `31`, so the shifted right operand is `0x80000000`; the word OR also keeps bit `0` of `a0`, so the published word is `0xFFFFFFFF80000001`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
orw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| orw_32_84f7ac2ed68f | L32 | 32 | 0x00003025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| orw_32_84f7ac2ed68f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| orw_32_84f7ac2ed68f | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| orw_32_84f7ac2ed68f | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| orw_32_84f7ac2ed68f | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| orw_32_84f7ac2ed68f | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| orw_32_84f7ac2ed68f | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| orw_32_84f7ac2ed68f | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| orw_32_84f7ac2ed68f | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractOperation_ORW()
    => ScalarOperation
begin
    return ScalarOperation_ORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORW.asl -->
```asl
readonly func InstructionContractHandler_ORW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_ORW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_ORW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_ORW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_ORW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_ORW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_OR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_ORW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORW()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; ORW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise inclusive OR with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
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

- ORW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- orw a0, a1, ->a2
- orw t#1, u#1.not<<1, ->u
- orw zero, a0.sw, ->zero
