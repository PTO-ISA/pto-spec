<!-- GENERATED FROM: asl/scalar/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/scalar/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL","surface":"scalar","classification":["model","dispatch","top-level"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-ALU","PTO-SCALAR-MODEL-DISPATCH-BRU","PTO-SCALAR-MODEL-DISPATCH-SYS","PTO-SCALAR-MODEL-DISPATCH-AMO","PTO-SCALAR-MODEL-DISPATCH-AGU","PTO-SCALAR-MODEL-DISPATCH-FSU"],"catalog_projection":{"catalog":"scalar-forms","family_constraints":[],"isa":"PTO Instruction Set Architecture","schema_version":2}}
// NDF-BEGIN: PTO-REQ-SCALAR-BODY-ENTRY-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// After a BSTART header, the first successfully decoded scalar form MUST enter
// the active block body before operation applicability is evaluated.  A value
// that does not decode as a scalar form MUST NOT change the header/body phase.
// NDF-END: PTO-REQ-SCALAR-BODY-ENTRY-001
func ExecuteScalarInstruction(instruction: bits(48),
                              length_bits: integer {16,32,48})
                              => ScalarExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeScalarForm(instruction, length_bits);
    if decoded == PTO_SCALAR_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_SCALAR_FORM_COUNT-1};
    let operation = ScalarOperationOfForm(form);
    if BundleIsActive() && !BundleBodyIsActive() then
        EnterBundleBody();
    end;
    if !ScalarOperationApplicable(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarRegisterOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarImplicitSourceOperandsLegal(operation) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    case ScalarFamilyOfForm(form) of
        when ScalarSemantic_AGU => ExecuteDecodedAGUForm(instruction, form);
        when ScalarSemantic_ALU => ExecuteDecodedALUForm(instruction, form);
        when ScalarSemantic_AMO => ExecuteDecodedAMOForm(instruction, form);
        when ScalarSemantic_BRU => ExecuteDecodedBRUForm(instruction, form);
        when ScalarSemantic_FSU => ExecuteDecodedFSUForm(instruction, form);
        when ScalarSemantic_SYS => ExecuteDecodedSYSForm(instruction, form);
        otherwise => unreachable;
    end;
    if _LastFault != Fault_None then
        return ScalarExecution_Rejected;
    end;
    if !ScalarHandlerWritesTPC(ScalarHandlerOfForm(form)) then
        WriteTPC(ReadTPC() + NaturalToWord(length_bits DIV 8));
    end;
    return ScalarExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
