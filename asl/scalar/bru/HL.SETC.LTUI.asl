// PTO-INSTRUCTION: {"assembly":["hl.setc.ltui SrcL, uimm"],"block":[],"catalog_indices":[272],"catalog_records":[{"asm":"hl.setc.ltui SrcL, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00006075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_setc_ltui_48_cb7a12ba6ead","length_bits":48,"mnemonic":"HL.SETC.LTUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","semantic_summary":"HL.SETC.LTUI - Compare scalar operands and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.setc.ltui SrcL, uimm"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.setc.ltui SrcL, uimm"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","shamt":"Encoded zero performs no shift.","uimm24":"Encoded zero supplies numeric zero for the 24-bit unsigned immediate."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"shamt","role":"shift amount"},{"field":"uimm24","role":"24-bit unsigned immediate"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["HL.SETC.LTUI - Compare scalar operands and update the bundle commit condition.","After decode and legality checks, execute the normative ExecuteSetCommit ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SETC-LTUI","mnemonic":"HL.SETC.LTUI","summary":"HL.SETC.LTUI - Compare scalar operands and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_LTUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_HL_SETC_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_HL_SETC_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_SETC_LTUI(),
        left,
        right);
end;
// DOC-END: operation
