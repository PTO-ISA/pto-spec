// PTO-INSTRUCTION: {"assembly":["b.z label"],"block":[],"catalog_indices":[19],"catalog_records":[{"asm":"b.z label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001037","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm22","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}],"signedness":"signed","width":22}],"form_id":"b_z_32_753dd3b4fcb6","length_bits":32,"mnemonic":"B.Z","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","semantic_summary":"B.Z - Conditionally branch to the PC-relative target after comparing scalar operands.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["b.z label"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["b.z label"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"simm22":"Encoded zero supplies numeric zero for the 22-bit signed immediate or displacement."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"simm22","role":"22-bit signed immediate or displacement"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["B.Z - Conditionally branch to the PC-relative target after comparing scalar operands.","After decode and legality checks, execute the normative BranchRelative ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-B-Z","mnemonic":"B.Z","summary":"B.Z - Conditionally branch to the PC-relative target after comparing scalar operands.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_Z() => ScalarOperation
begin
    return ScalarOperation_B_Z;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_Z() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;

pure func InstructionContractCondition_B_Z()
    => ScalarCondition
begin
    return ScalarCondition_Z;
end;

pure func InstructionContractBranchResult_B_Z(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_B_Z(),
        left,
        right);
end;
// DOC-END: operation
