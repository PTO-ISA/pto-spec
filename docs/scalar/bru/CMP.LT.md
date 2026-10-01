<!-- GENERATED FROM: asl/scalar/bru/CMP.LT.asl -->
# CMP.LT

**Normative ASL source:** `asl/scalar/bru/CMP.LT.asl`

CMP.LT - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-LT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-lt-purpose role=purpose -->
## What CMP.LT does

`CMP.LT` evaluates a signed less-than relation and writes a canonical XLEN boolean to a destination: `1` when the condition holds, `0` when it does not.

The result is ordinary data. `CMP.LT` does not set the commit condition of the enclosing block and does not touch any predicate register.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteCompare`. The model reads the left source, prepares the right operand, tests the condition `ScalarCondition_LT`, and writes `Zeros{PTO_XLEN} + 1` or `Zeros{PTO_XLEN}` through the destination selector.

`SrcRType` selects a transformation of the `SrcR` snapshot before the relation is tested. Value `1` substitutes the sign-extended low `32` bits and value `2` the zero-extended low `32` bits. Values `0` and `3` are both defined and both leave the complete value unchanged: the model passes an `11` modifier through untransformed, so no `SrcRType` encoding is reserved and only `1` and `2` change the compared value.

Design point: `CMP.AND` and `CMP.OR` are the register-form comparisons that apply a `.not` modifier, through a different modifier decoder. For the relation forms, `cmp.eq` and its siblings, the value the program placed in `SrcR` is the value the relation tests.

The relation is tested over signed XLEN values: the model compares the signed reading of the left operand with the signed reading of the prepared right operand, so the answer does not follow from which pattern is larger when both are read as unsigned integers.

Design point: canonicalizing to exactly `1` or `0` rather than to an arbitrary nonzero value means two comparisons can be combined arithmetically, and a single test of the destination is enough to recover the relation.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` and `SrcR` are Reg5 sources: codes `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.
- `SrcRType` selects the transformation of the `SrcR` snapshot: `1` substitutes the sign-extended low `32` bits and `2` the zero-extended low `32` bits, while `0` and `3` both leave the complete value unchanged.

`RegDst` names the destination: codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the result, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue.

Code `0` in either source reads the architectural zero GPR. Queue sources are read without being consumed.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-effects role=effects -->
## Effects and ordering

On success the instruction writes exactly one destination value and advances `TPC` by `4` bytes, the encoded length of the `32`-bit form.

It has no memory effect, no reservation effect, no descriptor effect, and no numeric status flag. It leaves the commit argument, the block argument, and the block condition marker unchanged, because it is not a condition setter.

The model reads every selected register source before writing the destination. Scalar dispatch advances `TPC` only after that destination effect.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-constraints role=constraints -->
## Legality and fault order

Decode runs first, and a fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any effect.

All `32` encodings of `SrcL`, `SrcR`, and `RegDst` are assigned, and all four `SrcRType` values are defined, so no register or modifier encoding is reserved.

A selected `T` or `U` source that is not available is rejected during operand legality, before the destination is written. A rejected instruction changes neither the destination nor `TPC`, and trap entry saves the original `TPC` so it can be reissued.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-example role=example -->
## Non-normative example

Set GPR1 to `5` and GPR2 to `6`.

`cmp.lt 1, 2, ->0` writes `1` into the destination. With GPR2 set to `5` the same form writes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.lt SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_lt_32_c0b8cc320f12 | L32 | 32 | 0x00004045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_lt_32_c0b8cc320f12 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_lt_32_c0b8cc320f12 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_lt_32_c0b8cc320f12 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_lt_32_c0b8cc320f12 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_lt_32_c0b8cc320f12 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_lt_32_c0b8cc320f12 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_lt_32_c0b8cc320f12 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_lt_32_c0b8cc320f12 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.LT.asl -->
```asl
readonly func InstructionContractOperation_CMP_LT() => ScalarOperation
begin
    return ScalarOperation_CMP_LT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.LT.asl -->
```asl
readonly func InstructionContractHandler_CMP_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_LT()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCompareResult_CMP_LT(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_LT(),
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

- CMP.LT - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.lt SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
