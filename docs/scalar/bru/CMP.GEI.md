<!-- GENERATED FROM: asl/scalar/bru/CMP.GEI.asl -->
# CMP.GEI

**Normative ASL source:** `asl/scalar/bru/CMP.GEI.asl`

CMP.GEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-gei-purpose role=purpose -->
## What CMP.GEI does

`CMP.GEI` evaluates a signed greater-than-or-equal relation and writes a canonical XLEN boolean to a destination: `1` when the condition holds, `0` when it does not.

The result is ordinary data. `CMP.GEI` does not set the commit condition of the enclosing block and does not touch any predicate register.

<!-- PTO-READER-BLOCK: scalar-cmp-gei-mechanism role=mechanism -->
## Mechanism

The contract returns `ScalarHandler_ExecuteCompare`. The model reads the left source, prepares the right operand, tests the condition `ScalarCondition_GE`, and writes `Zeros{PTO_XLEN} + 1` or `Zeros{PTO_XLEN}` through the destination selector.

The right operand is `simm12`, a `12`-bit signed immediate that the decoder sign-extends to XLEN. The relation itself is signed, so both sides are read as signed integers and the sign extension of the immediate matches the reading used by the comparison.

Design point: sign-extending the immediate rather than the relation is not a separate choice here. Because both sides are read as signed XLEN values, a negative immediate is the only way to express a signed bound below zero in one instruction.

Design point: canonicalizing to exactly `1` or `0` rather than to an arbitrary nonzero value means two comparisons can be combined arithmetically, and a single test of the destination is enough to recover the relation.

<!-- PTO-READER-BLOCK: scalar-cmp-gei-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `SrcL` supplies the left absolute GPR source.
- `simm12` supplies the `12`-bit signed immediate.

`RegDst` names the destination: codes `1..23` write the named absolute GPR, code `0` and codes `24..29` discard the result, code `30` pushes it to the `U` queue, and code `31` pushes it to the `T` queue.

Encoded zero in `SrcL` names the architectural zero GPR. Sources are read as values and are not consumed.

<!-- PTO-READER-BLOCK: scalar-cmp-gei-effects role=effects -->
## Effects and ordering

On success the instruction writes exactly one destination value and advances `TPC` by `4` bytes, the encoded length of the `32`-bit form.

It has no memory effect, no reservation effect, no descriptor effect, and no numeric status flag. It leaves the commit argument, the block argument, and the block condition marker unchanged, because it is not a condition setter.

Design point: because the comparison cannot observe the commit condition or install a control-flow target, a compiler can reorder it freely among other pure scalar operations up to the point where its destination is read.

<!-- PTO-READER-BLOCK: scalar-cmp-gei-constraints role=constraints -->
## Legality and fault order

Decode runs first, and a fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any effect.

All `4096` patterns of `simm12` are assigned; there is no reserved immediate.

A selected `T` or `U` source that is not available is rejected during operand legality, before the destination is written. A rejected instruction changes neither the destination nor `TPC`, and trap entry saves the original `TPC` so it can be reissued.

<!-- PTO-READER-BLOCK: scalar-cmp-gei-example role=example -->
## Non-normative example

Set GPR1 to `5`.

`cmp.gei 1, 5, ->0` writes `1` into the destination. With `simm12` set to `6` the same form writes `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.gei SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | L32 | 32 | 0x00005055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractOperation_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_CMP_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractHandler_CMP_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_GEI()
    => ScalarCondition
begin
    return ScalarCondition_GE;
end;

pure func InstructionContractCompareResult_CMP_GEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_GEI(),
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

- CMP.GEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.gei SrcL, simm, ->{t, u, Rd}
