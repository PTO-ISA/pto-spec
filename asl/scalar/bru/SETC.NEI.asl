// PTO-INSTRUCTION: {"assembly":["setc.nei SrcL, simm"],"block":[],"catalog_indices":[419],"catalog_records":[{"asm":"setc.nei SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_nei_32_fa01e973ab76","length_bits":32,"mnemonic":"SETC.NEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","semantic_summary":"SETC.NEI - Compare scalar operands and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["setc.nei SrcL, simm"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["setc.nei SrcL, simm"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","shamt":"Encoded zero performs no shift.","simm12":"Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"shamt","role":"shift amount"},{"field":"simm12","role":"12-bit signed immediate or displacement"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["SETC.NEI - Compare scalar operands and update the bundle commit condition.","After decode and legality checks, execute the normative ExecuteSetCommit ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SETC-NEI","mnemonic":"SETC.NEI","summary":"SETC.NEI - Compare scalar operands and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_NEI() => ScalarOperation
begin
    return ScalarOperation_SETC_NEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_NEI()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCommitResult_SETC_NEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_NEI(),
        left,
        right);
end;
// DOC-END: operation
