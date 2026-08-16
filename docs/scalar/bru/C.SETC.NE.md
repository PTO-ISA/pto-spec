<!-- GENERATED FROM: asl/scalar/bru/C.SETC.NE.asl -->
# C.SETC.NE

**Normative ASL source:** `asl/scalar/bru/C.SETC.NE.asl`

C.SETC.NE - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-C-SETC-NE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.setc.ne srcL, srcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | C16 | 16 | 0x0036 / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setc_ne_16_e9092e487e98 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| c_setc_ne_16_e9092e487e98 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractOperation_C_SETC_NE() => ScalarOperation
begin
    return ScalarOperation_C_SETC_NE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.SETC.NE.asl -->
```asl
readonly func InstructionContractHandler_C_SETC_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_C_SETC_NE()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCommitResult_C_SETC_NE(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_SETC_NE(),
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

- C.SETC.NE - Compare scalar operands and update the bundle commit condition.
- After decode and legality checks, execute the normative ExecuteSetCommit ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- c.setc.ne srcL, srcR

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
