<!-- GENERATED FROM: asl/scalar/bru/CMP.AND.asl -->
# CMP.AND

**Normative ASL source:** `asl/scalar/bru/CMP.AND.asl`

CMP.AND - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-CMP-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-and-purpose role=purpose -->
## What CMP.AND does

`CMP.AND` applies bitwise AND to two decoded scalar values and publishes whether the combined value is nonzero.

<!-- PTO-READER-BLOCK: scalar-cmp-and-mechanism role=mechanism -->
## Mechanism

Sources are snapshotted before bitwise AND.

A zero combined word becomes XLEN zero; any nonzero word becomes XLEN one.

<!-- PTO-READER-BLOCK: scalar-cmp-and-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `SrcR` supplies the right scalar source.

- `SrcRType` selects the right-source transformation.

<!-- PTO-READER-BLOCK: scalar-cmp-and-effects role=effects -->
## Effects and ordering

The canonical boolean is published through the encoded destination, then `TPC` advances by `4` bytes.

The instruction does not modify commit state and does not access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-cmp-and-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-cmp-and-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}` publishes XLEN one when its condition is true and XLEN zero otherwise.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_and_32_036813a12ae8 | L32 | 32 | 0x00002045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_and_32_036813a12ae8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_and_32_036813a12ae8 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_and_32_036813a12ae8 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_and_32_036813a12ae8 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_and_32_036813a12ae8 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_and_32_036813a12ae8 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractOperation_CMP_AND() => ScalarOperation
begin
    return ScalarOperation_CMP_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.AND.asl -->
```asl
readonly func InstructionContractHandler_CMP_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_CMP_AND()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareLogicalValue_CMP_AND(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_CMP_AND() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- CMP.AND - Combine scalar comparison results with the encoded logical operation.
- After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.and SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}
