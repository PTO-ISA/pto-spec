// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL","surface":"scalar","classification":["model","dispatch","top-level"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-ALU","PTO-SCALAR-MODEL-DISPATCH-BRU","PTO-SCALAR-MODEL-DISPATCH-SYS","PTO-SCALAR-MODEL-DISPATCH-AMO","PTO-SCALAR-MODEL-DISPATCH-AGU","PTO-SCALAR-MODEL-DISPATCH-FSU"],"catalog_projection":{"catalog":"scalar-forms","family_constraints":[],"isa":"PTO Instruction Set Architecture","schema_version":2}}
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
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarRegisterOperandsLegal(instruction, form) then
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
