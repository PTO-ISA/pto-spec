<!-- GENERATED FROM: asl/scalar/alu/CSEL.asl -->
# CSEL

**Normative ASL source:** `asl/scalar/alu/CSEL.asl`

CSEL snapshots three Reg5 sources, selects SrcL for a nonzero predicate or its optionally negated SrcR for zero, and publishes through the common scalar destination map.

## Normative identity {#PTO-INST-SCALAR-CSEL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-csel-purpose role=purpose -->
## What CSEL does

`CSEL` reads three Reg5 sources and publishes one of two candidate values: the true-value source when the predicate source is not all zero, otherwise the false-value source after an optional negation chosen by the encoding.

Design point: the predicate test is "not all zero", so any nonzero bit pattern is true, including a value whose only set bit is far from bit zero. A caller can pass a mask or a comparison result straight in as the condition instead of normalizing it to `0` or `1`.

<!-- PTO-READER-BLOCK: scalar-csel-mechanism role=mechanism -->
## How the result is formed

All three sources are snapshotted. The false candidate is prepared first: raw `SrcRType` codes `00`, `01` and `10` leave `SrcR` unchanged, and raw `11` replaces it with `0 - SrcR` computed modulo `2^PTO_XLEN`. The selection then publishes the true candidate if the predicate snapshot is nonzero, and the prepared false candidate if it is zero.

Design point: the modifier is applied to the false candidate before the selection, so a negation can never reach the true value. In `csel a0, a1, a2.neg, ->a3` the two possible results are `a1` and `-a2`, and there is no way to negate `a1` in this form.

Design point: three of the four `SrcRType` codes mean "unchanged", so an assembler that omits `.neg` must choose one of them, and the remaining two stay legal encodings of the same operation. Two instruction streams can differ in those bits and still produce identical results.

Design point: negation wraps modulo `2^PTO_XLEN` and does not fault, so negating the most negative value republishes that same value rather than overflowing.

<!-- PTO-READER-BLOCK: scalar-csel-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcP` is the predicate: an all-zero value selects the false candidate and every nonzero value selects the true candidate.
- `SrcL` is the true-value source and `SrcR` the false-value source; both use the Reg5 map, where codes `0..23` are absolute GPRs, `24..27` are `T#1..T#4` and `28..31` are `U#1..U#4`, read without consuming a queue entry.
- `SrcRType` is the two-bit false-source modifier selector: `00`, `01` and `10` are unmodified aliases, and `11` is `.neg`.
- `RegDst` publishes the selected value through the common destination map: codes `0` and `24..29` discard, `1..23` write a GPR, `30` pushes `U`, and `31` pushes `T`.

Design point: encoded zero of `SrcP` reads the architectural zero GPR, so `csel zero, a0, a1, ->a2` always publishes `a1`. The predicate is a real operand in every encoding, never an omitted field.

<!-- PTO-READER-BLOCK: scalar-csel-effects role=effects -->
## Effects and ordering

All three sources are read eagerly and non-consumingly before the destination write, even when the predicate outcome does not select one of them. A destination that aliases a source therefore sees the pre-instruction value: `csel a0, a1, a2, ->a0` tests the old `a0`. The selected value is then published once.

`TPC` advances by `4` bytes. Only a `T` or `U` destination push changes a temporary queue; no memory, reservation, descriptor, numeric-status, block, privilege, branch-target or other control state changes.

<!-- PTO-READER-BLOCK: scalar-csel-constraints role=constraints -->
## Legality and fault boundary

All four `SrcRType` values are assigned, every value of each Reg5 selector is assigned, and the fixed encoding bits must match the canonical form. No operand of `CSEL` is reserved.

An unavailable selected `T` or `U` queue source raises `Fault_IllegalInstruction` before the destination effect and before `TPC` advances, including a source that the predicate outcome does not select. `CSEL` raises no arithmetic, memory, alignment, permission or control-flow exception.

Design point: the preflight covers the encoded selectors rather than the value that wins, so `csel t#1, a0, u#1, ->a2` faults when `U#1` is unavailable even if a nonzero `T#1` would publish `a0`. The fault decision is fixed by the encoding before the predicate is consulted.

<!-- PTO-READER-BLOCK: scalar-csel-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

With `a0` holding `5`, `a1` holding `7` and `a2` holding `9`, `csel a0, a1, a2, ->a3` publishes `7`, because a nonzero predicate selects the true candidate. With `a0` holding `0` the same instruction publishes `9`, and `csel a0, a1, a2.neg, ->a3` publishes `-9`. The canonical form `csel t#1, u#1, a0.neg, ->u` reads the predicate from `T#1` and the true candidate from `U#1`, neither of which is consumed.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | L32 | 32 | 0x00000077 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| csel_32_ba77cbad3c99 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcP | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| csel_32_ba77cbad3c99 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| csel_32_ba77cbad3c99 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| csel_32_ba77cbad3c99 | SrcL | 5 | 0–31 | none | none | Reg5 true-value source | Encoded zero reads the architectural zero GPR. |
| csel_32_ba77cbad3c99 | SrcP | 5 | 0–31 | none | none | Reg5 predicate source | Encoded zero reads the architectural zero GPR and therefore selects the false value. |
| csel_32_ba77cbad3c99 | SrcR | 5 | 0–31 | none | none | Reg5 false-value source | Encoded zero reads the architectural zero GPR. |
| csel_32_ba77cbad3c99 | SrcRType | 2 | 0–3 | none | none | CSEL-specific false-source modifier selector | Encoded zero is an assigned unmodified false-source alias. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcP | Reg5 predicate source |
| SrcL | Reg5 true-value source |
| SrcR | Reg5 false-value source |
| SrcRType | CSEL-specific false-source modifier selector |
| RegDst | Reg5 destination or discard |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractOperation_CSEL()
    => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;

pure func InstructionContractRightModifier_CSEL(encoded: bits(2))
    => ScalarRightModifier
begin
    return DecodeScalarSelectRightModifier(encoded);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CSEL.asl -->
```asl
readonly func InstructionContractHandler_CSEL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;

pure func InstructionContractFalseValue_CSEL(
    right: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let modifier = InstructionContractRightModifier_CSEL(encoded_modifier);
    return ApplySelectModifier(right, modifier);
end;

pure func InstructionContractResult_CSEL(
    predicate: Word,
    selected_true: Word,
    selected_false: Word,
    encoded_modifier: bits(2))
    => Word
begin
    let prepared_false = InstructionContractFalseValue_CSEL(
        selected_false,
        encoded_modifier);
    return ScalarConditionalSelect(
        predicate,
        selected_true,
        prepared_false);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcP, SrcL, SrcR, SrcRType, and RegDst are required encoded fields; no field can be omitted.
- Assembly without .neg uses the canonical unmodified alias selected by the assembler. Raw SrcRType codes 00, 01, and 10 are assigned unmodified aliases; raw code 11 is .neg.

## Legality

- SrcP, SrcL, and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- All four SrcRType values are assigned. Codes 00, 01, and 10 leave SrcR unchanged; code 11 negates the complete XLEN value modulo 2^PTO_XLEN.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.

## State effects

- Snapshot SrcP, SrcL, and SrcR before any destination effect. Only an all-zero SrcP is false; every nonzero bit pattern is true.
- For a true predicate publish the complete snapshotted SrcL. For a false predicate publish the complete snapshotted SrcR after the CSEL-specific raw modifier; negation wraps modulo 2^PTO_XLEN and does not fault.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Read all three Reg5 sources eagerly and non-consumingly before the destination write, even when the predicate outcome does not select one value.
- Publish the selected value, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U queue source raises Fault_IllegalInstruction before the destination effect and before TPC advances, including a source not selected by the predicate outcome.
- CSEL raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- csel a0, a1, a2, ->a3
- csel t#1, u#1, a0.neg, ->u
- csel zero, a0, a1, ->zero
