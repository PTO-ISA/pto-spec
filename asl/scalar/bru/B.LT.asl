// PTO-INSTRUCTION: {"assembly":["b.lt SrcL, SrcR, label"],"block":[],"catalog_indices":[15],"catalog_records":[{"asm":"b.lt SrcL, SrcR, label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002027","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"b_lt_32_2ca5ecd25cfb","length_bits":32,"mnemonic":"B.LT","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","semantic_summary":"B.LT - Conditionally branch to the PC-relative target after comparing scalar operands.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["b.lt SrcL, SrcR, label"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["b.lt SrcL, SrcR, label"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","SrcR":"Encoded zero names the architectural zero GPR.","simm12":"Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"SrcR","role":"right absolute GPR source"},{"field":"simm12","role":"12-bit signed immediate or displacement"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["B.LT - Conditionally branch to the PC-relative target after comparing scalar operands.","After decode and legality checks, execute the normative BranchRelative ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-B-LT","mnemonic":"B.LT","summary":"B.LT - Conditionally branch to the PC-relative target after comparing scalar operands.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_LT() => ScalarOperation
begin
    return ScalarOperation_B_LT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;

pure func InstructionContractCondition_B_LT()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractBranchResult_B_LT(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_B_LT(),
        left,
        right);
end;
// DOC-END: operation
