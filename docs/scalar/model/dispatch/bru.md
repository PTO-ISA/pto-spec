<!-- GENERATED FROM: asl/scalar/model/dispatch/bru.asl -->
# BRU

**Normative ASL source:** `asl/scalar/model/dispatch/bru.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-BRU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-purpose role=purpose-scope -->
## Purpose and scope

This unit executes every decoded scalar branch-unit form: comparisons (`CMP.*`, `C.CMP.*`), commit-condition setters (`SETC.*`, `C.SETC.*`), jumps (`J`, `JR`), and PC-relative helpers (`ADDTPC`, `SETRET`, and their `HL` forms).

`ExecuteDecodedBRUForm` switches on the operation, picks the immediate field, and calls a helper from [BRU semantics](../bru/semantics.md). `ScalarConditionForOperation` maps each relational compare or setter mnemonic to one `ScalarCondition`: EQ, NE, LT, GE, LTU, or GEU.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-concepts role=concepts-state -->
## Concepts and visible state

For comparison and setter forms, the immediate field follows the mnemonic:

| Forms | Field |
| --- | --- |
| signed 32-bit forms, such as `CMP.LTI`, `SETC.EQI`, `CMP.ANDI` | `simm12` |
| unsigned 32-bit forms, `CMP.LTUI`, `CMP.GEUI`, `SETC.LTUI`, `SETC.GEUI` | `uimm12` |
| signed 48-bit `HL` forms | `simm24` |
| unsigned 48-bit `HL` forms | `uimm24` |
| `C.CMP.EQI`, `C.CMP.NEI` | `simm5` |

Signed fields are sign-extended and unsigned fields are zero-extended to 64 bits.

The right operand of a register comparison may carry a `SrcRType` modifier. Relational comparisons and setters use `ApplyRestrictedCompareModifier`, so raw `11` means no change. The logical `CMP.AND`, `CMP.OR`, `SETC.AND`, and `SETC.OR` forms use the full modifier with `logical_family` TRUE, so raw `11` applies bitwise NOT.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-rules role=rules-interactions -->
## Rules and interactions

Comparison forms write a 0 or 1 word through the Reg5 destination rules. Setter forms write `_CommitArgument` and, inside a bundle, `_BARG.taken`.

Immediate `SETC.*` forms shift the extended immediate left by the decoded `shamt` before comparing. Immediate `CMP.*` forms do not shift.

Design point: only the setters shift their immediate. The same 12-bit or 24-bit field therefore reaches a wider range of constants in a `SETC.*` form than in the matching `CMP.*` form. The shift is plain 64-bit arithmetic; bits shifted out are lost.

`C.CMP.EQI` and `C.CMP.NEI` read T#1 as the left operand and push the result to T (selector 31). The old T#1 becomes T#2.

`J` adds its halfword offset from `simm22` to TPC. `JR` reads `SrcL`, adds `simm12` shifted left by 1, and faults on an odd target.

`ADDTPC` and `HL.ADDTPC` sign-extend `imm20` or `imm32` and add it, shifted left by 12, to TPC. `SETRET` and `HL.SETRET` zero-extend `imm20` or `imm32` and write TPC plus the value shifted left by 1 to GPR 10 and to `_ReturnAddress`.

Design point: `SETRET` is written as a separate form with a fixed destination. The broader `ADDTPC` and `HL.ADDTPC` encodings exclude `RegDst == 10`, and two of the three reviewed overlaps listed by top-level dispatch give that slot to `SETRET` and `HL.SETRET`; the third gives the `C.MOVI` slot to `C.SETRET`, which ALU dispatch executes.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-boundaries role=boundaries -->
## Architectural boundaries

Whether a setter is allowed in the current bundle is checked earlier, by `ScalarOperationApplicable` in top-level dispatch. It requires an active conditional bundle body whose condition is not yet set; otherwise the instruction raises `Fault_BundleControl` before the setter runs; only the body-entry transition made by top-level dispatch remains.

Only `J` and `JR` install TPC here; top-level dispatch advances TPC for every other BRU form after success.

`ScalarImplicitSourceOperandsLegal` checks T#1 availability for `C.SDI`, `C.SLLI`, `C.SRLI`, and `C.SWI`. It does not list `C.CMP.EQI` or `C.CMP.NEI`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-example role=example-usage -->
## Non-normative reading example

Take the 32-bit word 0xFFF1C275. It matches `SETC.LTI` (mask 0x707F, match 0x4075).

| Field | Bits | Raw | Value |
| --- | --- | --- | --- |
| `shamt` | 11:7 | 4 | shift by 4 |
| `SrcL` | 19:15 | 3 | GPR 3 |
| `simm12` | 31:20 | 0xFFF | -1 |

The right operand is -1 shifted left by 4, which is -16. If GPR 3 holds -20, the signed test `-20 < -16` is true. `_CommitArgument` becomes 1, `_BARG.taken` becomes TRUE, and `_BundleConditionSet` becomes TRUE.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-bru-related role=related-owners-navigation -->
## Related owners

- [BRU semantics](../bru/semantics.md) owns conditions, setters, jumps, and PC-relative helpers.
- [Scalar decode helpers](decode.md) own the comparison modifier table.
- [SYS semantics](../sys/semantics.md) owns `ScalarOperationApplicable`.
- [Scalar top-level dispatch](top-level.md) owns TPC advance and the reviewed encoding overlaps.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/bru.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-BRU","surface":"scalar","classification":["model","dispatch","bru"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-BRU-SEMANTICS","PTO-SCALAR-ADDTPC","PTO-SCALAR-C-CMP-EQI","PTO-SCALAR-C-CMP-NEI","PTO-SCALAR-C-SETC-EQ","PTO-SCALAR-C-SETC-NE","PTO-SCALAR-CMP-AND","PTO-SCALAR-CMP-ANDI","PTO-SCALAR-CMP-EQ","PTO-SCALAR-CMP-EQI","PTO-SCALAR-CMP-GE","PTO-SCALAR-CMP-GEI","PTO-SCALAR-CMP-GEU","PTO-SCALAR-CMP-GEUI","PTO-SCALAR-CMP-LT","PTO-SCALAR-CMP-LTI","PTO-SCALAR-CMP-LTU","PTO-SCALAR-CMP-LTUI","PTO-SCALAR-CMP-NE","PTO-SCALAR-CMP-NEI","PTO-SCALAR-CMP-OR","PTO-SCALAR-CMP-ORI","PTO-SCALAR-HL-ADDTPC","PTO-SCALAR-HL-CMP-ANDI","PTO-SCALAR-HL-CMP-EQI","PTO-SCALAR-HL-CMP-GEI","PTO-SCALAR-HL-CMP-GEUI","PTO-SCALAR-HL-CMP-LTI","PTO-SCALAR-HL-CMP-LTUI","PTO-SCALAR-HL-CMP-NEI","PTO-SCALAR-HL-CMP-ORI","PTO-SCALAR-HL-SETC-ANDI","PTO-SCALAR-HL-SETC-EQI","PTO-SCALAR-HL-SETC-GEI","PTO-SCALAR-HL-SETC-GEUI","PTO-SCALAR-HL-SETC-LTI","PTO-SCALAR-HL-SETC-LTUI","PTO-SCALAR-HL-SETC-NEI","PTO-SCALAR-HL-SETC-ORI","PTO-SCALAR-HL-SETRET","PTO-SCALAR-J","PTO-SCALAR-JR","PTO-SCALAR-SETC-AND","PTO-SCALAR-SETC-ANDI","PTO-SCALAR-SETC-EQ","PTO-SCALAR-SETC-EQI","PTO-SCALAR-SETC-GE","PTO-SCALAR-SETC-GEI","PTO-SCALAR-SETC-GEU","PTO-SCALAR-SETC-GEUI","PTO-SCALAR-SETC-LT","PTO-SCALAR-SETC-LTI","PTO-SCALAR-SETC-LTU","PTO-SCALAR-SETC-LTUI","PTO-SCALAR-SETC-NE","PTO-SCALAR-SETC-NEI","PTO-SCALAR-SETC-OR","PTO-SCALAR-SETC-ORI","PTO-SCALAR-SETRET"]}
pure func ScalarConditionForOperation(operation: ScalarOperation) => ScalarCondition
begin
    case operation of
        when ScalarOperation_C_CMP_EQI,
             ScalarOperation_C_SETC_EQ, ScalarOperation_CMP_EQ,
             ScalarOperation_CMP_EQI, ScalarOperation_HL_CMP_EQI,
             ScalarOperation_HL_SETC_EQI, ScalarOperation_SETC_EQ,
             ScalarOperation_SETC_EQI => return ScalarCondition_EQ;
        when ScalarOperation_C_CMP_NEI,
             ScalarOperation_C_SETC_NE, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_NEI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_SETC_NEI, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_NEI => return ScalarCondition_NE;
        when ScalarOperation_CMP_LT,
             ScalarOperation_CMP_LTI, ScalarOperation_HL_CMP_LTI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_SETC_LT,
             ScalarOperation_SETC_LTI => return ScalarCondition_LT;
        when ScalarOperation_CMP_GE,
             ScalarOperation_CMP_GEI, ScalarOperation_HL_CMP_GEI,
             ScalarOperation_HL_SETC_GEI, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_GEI => return ScalarCondition_GE;
        when ScalarOperation_CMP_LTU,
             ScalarOperation_CMP_LTUI, ScalarOperation_HL_CMP_LTUI,
             ScalarOperation_HL_SETC_LTUI, ScalarOperation_SETC_LTU,
             ScalarOperation_SETC_LTUI => return ScalarCondition_LTU;
        when ScalarOperation_CMP_GEU,
             ScalarOperation_CMP_GEUI, ScalarOperation_HL_CMP_GEUI,
             ScalarOperation_HL_SETC_GEUI, ScalarOperation_SETC_GEU,
             ScalarOperation_SETC_GEUI => return ScalarCondition_GEU;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedCompareRegister(instruction: bits(48),
                                   form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                   operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form));
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedCompareImmediate(instruction: bits(48),
                                    form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                    operation: ScalarOperation,
                                    immediate_field: ScalarOperandField)
begin
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field));
end;

func ExecuteDecodedCompareLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form), TRUE);
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedCompareLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field), combine_or);
end;

func ExecuteDecodedSetCommitRegister(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                     operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedSetCommitImmediate(instruction: bits(48),
                                      form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                      operation: ScalarOperation,
                                      immediate_field: ScalarOperandField)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate);
end;

func ExecuteDecodedSetCommitLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedComparisonRightModifier(instruction, form), TRUE);
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedSetCommitLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate, combine_or);
end;

func ExecuteDecodedBRUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_CMP_EQ, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_LT, ScalarOperation_CMP_GE,
             ScalarOperation_CMP_LTU, ScalarOperation_CMP_GEU =>
            ExecuteDecodedCompareRegister(instruction, form, operation);
        when ScalarOperation_CMP_EQI, ScalarOperation_CMP_NEI,
             ScalarOperation_CMP_LTI, ScalarOperation_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_CMP_LTUI, ScalarOperation_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_CMP_EQI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_CMP_LTI, ScalarOperation_HL_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_CMP_LTUI, ScalarOperation_HL_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_CMP_AND =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_CMP_OR =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);

        when ScalarOperation_C_CMP_EQI, ScalarOperation_C_CMP_NEI =>
            ExecuteCompare(31, ScalarConditionForOperation(operation),
                ReadScalarRegisterOperand(24),
                ScalarDecodedWord(instruction, form, ScalarField_simm5));

        when ScalarOperation_SETC_EQ, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_LT, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_LTU, ScalarOperation_SETC_GEU =>
            ExecuteDecodedSetCommitRegister(instruction, form, operation);
        when ScalarOperation_SETC_EQI, ScalarOperation_SETC_NEI,
             ScalarOperation_SETC_LTI, ScalarOperation_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_SETC_LTUI, ScalarOperation_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_SETC_EQI, ScalarOperation_HL_SETC_NEI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_HL_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_SETC_LTUI, ScalarOperation_HL_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_SETC_AND =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_SETC_OR =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);
        when ScalarOperation_C_SETC_EQ, ScalarOperation_C_SETC_NE =>
            ExecuteSetCommit(ScalarConditionForOperation(operation),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));

        when ScalarOperation_J =>
            JumpRelative(ScalarDecodedWord(instruction, form, ScalarField_simm22));
        when ScalarOperation_JR =>
            JumpRegister(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL) +
                LSL(ScalarDecodedWord(instruction, form, ScalarField_simm12), 1));

        when ScalarOperation_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        when ScalarOperation_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
