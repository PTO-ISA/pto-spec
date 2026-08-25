<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.ANDI.asl -->
# HL.CMP.ANDI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.ANDI.asl`

HL.CMP.ANDI - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-purpose role=purpose -->
## What HL.CMP.ANDI does

`HL.CMP.ANDI` applies bitwise AND to two decoded scalar values and publishes whether the combined value is nonzero.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-mechanism role=mechanism -->
## Mechanism

Sources are snapshotted before bitwise AND.

A zero combined word becomes XLEN zero; any nonzero word becomes XLEN one.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `simm24` supplies a signed encoded immediate.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-effects role=effects -->
## Effects and ordering

The canonical boolean is published through the encoded destination, then `TPC` advances by `6` bytes.

The instruction does not modify commit state and does not access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-andi-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`hl.cmp.andi SrcL, simm, ->{t, u, Rd}` publishes XLEN one when its condition is true and XLEN zero otherwise.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_andi_48_de2aae3f4516 | HL48 | 48 | 0x00002055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_andi_48_de2aae3f4516 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_andi_48_de2aae3f4516 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_andi_48_de2aae3f4516 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_andi_48_de2aae3f4516 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_andi_48_de2aae3f4516 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_andi_48_de2aae3f4516 | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_HL_CMP_ANDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareLogicalValue_HL_CMP_ANDI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_HL_CMP_ANDI() then
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

- HL.CMP.ANDI - Combine scalar comparison results with the encoded logical operation.
- After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.andi SrcL, simm, ->{t, u, Rd}
