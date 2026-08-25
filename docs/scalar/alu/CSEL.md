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

`CSEL` is a 32-bit scalar ALU instruction. It selects the left value for a nonzero predicate, otherwise selecting the optionally negated right value; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-csel-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then selects the left value for a nonzero predicate, otherwise selecting the optionally negated right value, and only afterward performs the destination effects.

- `SrcRType` chooses the right-source transformation before the operation-specific arithmetic or logical step.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-csel-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `SrcP` field selects the predicate value through Reg5.
- The 5-bit `SrcL` field selects the value used for a true predicate.
- The 5-bit `SrcR` field selects the value used for a false predicate.
- The 2-bit `SrcRType` field selects the CSEL transformation applied to the false-side source.
- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-csel-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-csel-constraints role=constraints -->
## Legality and fault boundary

All three sources are read before selection; an unavailable T/U source faults with `Fault_IllegalInstruction` before publication even when the predicate would choose the other side.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-csel-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `CSEL` example, predicate `0`, false-side value `3`, and the negating selector publish `-3` modulo `2^PTO_XLEN`.
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
