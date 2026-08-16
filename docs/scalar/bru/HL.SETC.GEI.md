<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.GEI.asl -->
# HL.SETC.GEI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.GEI.asl`

HL.SETC.GEI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.setc.gei SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_gei_48_9563d6395d06 | HL48 | 48 | 0x00005075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_gei_48_9563d6395d06 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_gei_48_9563d6395d06 | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_gei_48_9563d6395d06 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_gei_48_9563d6395d06 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_gei_48_9563d6395d06 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_gei_48_9563d6395d06 | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_GEI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.GEI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_GEI()
    => ScalarCondition
begin
    return ScalarCondition_GE;
end;

pure func InstructionContractCommitResult_HL_SETC_GEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_GEI(),
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

- HL.SETC.GEI - Compare scalar operands and update the bundle commit condition.
- After decode and legality checks, execute the normative ExecuteSetCommit ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.setc.gei SrcL, simm

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
