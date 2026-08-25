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

`CMP.LT` evaluates signed less-than over decoded scalar operands and publishes canonical XLEN one or zero.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-mechanism role=mechanism -->
## Mechanism

The instruction snapshots its operands, prepares the decoded right source, and then evaluates signed less-than.

A true relation becomes XLEN one; a false relation becomes XLEN zero.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `SrcR` supplies the right scalar source.

- `SrcRType` selects the right-source transformation.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-effects role=effects -->
## Effects and ordering

The canonical boolean is published through the encoded destination, then `TPC` advances by `4` bytes.

The instruction does not modify commit state and does not access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-cmp-lt-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`cmp.lt SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}` publishes XLEN one when its condition is true and XLEN zero otherwise.
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
