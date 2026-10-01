<!-- GENERATED FROM: asl/scalar/bru/CMP.EQI.asl -->
# CMP.EQI

**Normative ASL source:** `asl/scalar/bru/CMP.EQI.asl`

CMP.EQI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-EQI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-eqi-purpose role=purpose -->
## What CMP.EQI does

`CMP.EQI` evaluates equality and writes a canonical XLEN boolean to a destination: `1` when the condition holds, `0` when it does not.

The result is ordinary data. `CMP.EQI` does not set the commit condition of the enclosing block and does not touch any predicate register.

<!-- PTO-READER-BLOCK: scalar-cmp-eqi-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteCompare`. The model reads the left source, prepares the right operand, tests the condition `ScalarCondition_EQ`, and writes `Zeros{PTO_XLEN} + 1` or `Zeros{PTO_XLEN}` through the destination selector.

The right operand is `simm12`, a `12`-bit signed immediate that the decoder sign-extends to XLEN, so values from `-2048` to `2047` are available and `-1` compares as all ones.

Design point: canonicalizing to exactly `1` or `0` rather than to an arbitrary nonzero value means two comparisons can be combined arithmetically, and a single test of the destination is enough to recover the relation.

<!-- PTO-READER-BLOCK: scalar-cmp-eqi-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` is a Reg5 source: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `simm12` supplies the `12`-bit signed immediate.

`RegDst` names the destination: codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the result, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue.

Source code `0` reads the architectural zero GPR. A queue source is read without being consumed.

<!-- PTO-READER-BLOCK: scalar-cmp-eqi-effects role=effects -->
## Effects and ordering

On success the instruction writes exactly one destination value and advances `TPC` by `4` bytes, the encoded length of the `32`-bit form.

It has no memory effect, no reservation effect, no descriptor effect, and no numeric status flag. It leaves the commit argument, the block argument, and the block condition marker unchanged, because it is not a condition setter.

The model reads every selected register source before writing the destination. Scalar dispatch advances `TPC` only after that destination effect.

<!-- PTO-READER-BLOCK: scalar-cmp-eqi-constraints role=constraints -->
## Legality and fault order

Decode runs first, and a fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any effect.

All `4096` patterns of `simm12` are assigned; there is no reserved immediate, so nothing in the immediate field can be rejected.

A selected `T` or `U` source that is not available is rejected during operand legality, before the destination is written. A rejected instruction changes neither the destination nor `TPC`, and trap entry saves the original `TPC` so it can be reissued.

<!-- PTO-READER-BLOCK: scalar-cmp-eqi-example role=example -->
## Non-normative example

Set GPR1 to `5`.

`cmp.eqi 1, 5, ->0` writes `1` into the destination. With `simm12` set to `6` the same form writes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.eqi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_eqi_32_252943516dca | L32 | 32 | 0x00000055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_eqi_32_252943516dca | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_eqi_32_252943516dca | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_eqi_32_252943516dca | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_eqi_32_252943516dca | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_eqi_32_252943516dca | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_eqi_32_252943516dca | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.EQI.asl -->
```asl
readonly func InstructionContractOperation_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_CMP_EQI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.EQI.asl -->
```asl
readonly func InstructionContractHandler_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_EQI()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCompareResult_CMP_EQI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_EQI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- CMP.EQI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.eqi SrcL, simm, ->{t, u, Rd}
