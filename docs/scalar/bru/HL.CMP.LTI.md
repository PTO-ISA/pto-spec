<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.LTI.asl -->
# HL.CMP.LTI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.LTI.asl`

HL.CMP.LTI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-LTI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-purpose role=purpose -->
## What HL.CMP.LTI does

`HL.CMP.LTI` evaluates signed less-than over decoded scalar operands and publishes canonical XLEN one or zero.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-mechanism role=mechanism -->
## Mechanism

The instruction snapshots its operands, prepares the decoded immediate, and then evaluates signed less-than.

A true relation becomes XLEN one; a false relation becomes XLEN zero.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-inputs-outputs role=inputs-outputs -->
## Inputs and output

- `RegDst` selects the encoded destination or discard behavior.

- `SrcL` supplies the left scalar source.

- `simm24` supplies a signed encoded immediate.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-effects role=effects -->
## Effects and ordering

The canonical boolean is published through the encoded destination, then `TPC` advances by `6` bytes.

The instruction does not modify commit state and does not access memory or reservation state.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-constraints role=constraints -->
## Legality and fault order

Encoding, reserved field values, and source availability are checked before destination, control, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-hl-cmp-lti-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

`hl.cmp.lti SrcL, simm, ->{t, u, Rd}` publishes XLEN one when its condition is true and XLEN zero otherwise.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.lti SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_lti_48_bec21b77021a | HL48 | 48 | 0x00004055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_lti_48_bec21b77021a | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_lti_48_bec21b77021a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_lti_48_bec21b77021a | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_lti_48_bec21b77021a | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_lti_48_bec21b77021a | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_lti_48_bec21b77021a | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.LTI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_LTI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.LTI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_LTI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_LTI()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCompareResult_HL_CMP_LTI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_LTI(),
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

- HL.CMP.LTI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.lti SrcL, simm, ->{t, u, Rd}
