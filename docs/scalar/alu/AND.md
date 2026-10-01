<!-- GENERATED FROM: asl/scalar/alu/AND.asl -->
# AND

**Normative ASL source:** `asl/scalar/alu/AND.asl`

AND applies the selected right-source transformation before its encoded logical left shift, performs bitwise conjunction, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-and-purpose role=purpose -->
## What AND does

`AND` prepares a right source and computes the bit-by-bit conjunction of that value with an unchanged left source over all `PTO_XLEN` bits, then publishes the result through a Reg5 destination.

Design point: `AND` reuses the `ADD` field layout, so `SrcRType=10` is available here too. The shared modifier helper is called with the logical-family flag set, and that flag changes the meaning of that one code: in `AND` it is bitwise complement, in `ADD` it is negation. The identical encoding therefore produces a mask here and a subtraction there.

<!-- PTO-READER-BLOCK: scalar-and-mechanism role=mechanism -->
## How the result is formed

The right source is prepared in two steps, then the conjunction is taken.

- `SrcRType` transforms `SrcR`: `00` sign-extends `SrcR[31:0]`, `01` zero-extends `SrcR[31:0]`, `10` complements every bit, and `11` leaves the value unchanged. An omitted assembly suffix encodes `SrcRType=11`.
- `shamt` then shifts the transformed value logically left by `0` through `31` bits; bits shifted past bit `63` are discarded and the vacated low bits are zero.

The result is `SrcL AND prepared-right`, computed independently for each of the `64` bit positions.

Design point: shifting the right source before the conjunction moves the mask. `and a0, a1<<4, ->a2` ignores the low `4` bits of `a0` entirely, because the corresponding mask bits are zero.

Design point: complement and shift compose in one encoding. `and a0, a1.not<<3, ->a2` clears the low `3` bits of `a0` and then keeps only the positions where `a1` was zero.

<!-- PTO-READER-BLOCK: scalar-and-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` and `SrcR` are Reg5 sources: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`. Reading a temporary source does not consume it.
- `RegDst` publishes the result: `1..23` write that GPR, `30` pushes `U`, `31` pushes `T`, and `0` together with `24..29` discard it.

Design point: encoded zero of `SrcL` or `SrcR` reads the architectural zero GPR, which makes `and a0, zero, ->a1` a constant-zero materialization rather than a no-op, and makes `and a0, a0, ->a1` a copy. No field of `AND` can be omitted.

<!-- PTO-READER-BLOCK: scalar-and-effects role=effects -->
## Effects and ordering

Both sources are read before the destination is written, so `and a0, a0, ->a0` and any destination alias use the pre-instruction values.

The result is published or discarded, and then `TPC` advances by `4` bytes. `AND` performs no memory access and leaves reservation, descriptor, numeric-status, trap, bundle, privilege, predicate and control-flow state unchanged apart from the one `T` or `U` push selected by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-and-constraints role=constraints -->
## Legality and fault boundary

Every encoded value is assigned: all four `SrcRType` codes and all `32` `shamt` values from `0` through `31`. There is no reserved modifier and no reserved shift amount.

An undecodable form raises `Fault_IllegalInstruction` at `PC`; an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`; a fixed-bit mismatch or an unavailable selected T/U source raises `Fault_IllegalInstruction`. Each precedes the destination effect and the `TPC` advance.

Design point: a bitwise operation signals nothing, so `AND` has no fault beyond those checks. Complemented or shifted-out bits are simply absent from the result; there is no status flag that records them.

<!-- PTO-READER-BLOCK: scalar-and-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `SrcL=12`, `SrcR=10`, `SrcRType=11` and `shamt=0`, the conjunction is `12 AND 10 = 8`. With `SrcRType=10` on the same operands, the prepared right value is the complement of `10` and the published result is `12 AND NOT 10 = 4`. With `SrcRType=11` and `shamt=2`, the prepared right value is `40`, and `12 AND 40 = 8`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
and SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| and_32_b6a903a3ec94 | L32 | 32 | 0x00002005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| and_32_b6a903a3ec94 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| and_32_b6a903a3ec94 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| and_32_b6a903a3ec94 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| and_32_b6a903a3ec94 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| and_32_b6a903a3ec94 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| and_32_b6a903a3ec94 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| and_32_b6a903a3ec94 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| and_32_b6a903a3ec94 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractOperation_AND()
    => ScalarOperation
begin
    return ScalarOperation_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/AND.asl -->
```asl
readonly func InstructionContractHandler_AND()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_AND(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_AND(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_AND(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_AND(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_AND(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_AND, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_AND()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_AND()
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; AND uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the PTO_XLEN bitwise conjunction with SrcL.
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

- AND raises no arithmetic exception; transformed or shifted-out bits are discarded at PTO_XLEN width.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- and a0, a1, ->a2
- and t#1, u#1.not<<1, ->u
- and zero, a0.sw, ->zero
