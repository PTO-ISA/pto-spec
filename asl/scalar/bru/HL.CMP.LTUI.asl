// PTO-INSTRUCTION: {"assembly":["hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[134],"catalog_records":[{"asm":"hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00006055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_cmp_ltui_48_d12167277d58","length_bits":48,"mnemonic":"HL.CMP.LTUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","semantic_summary":"HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SrcL":"Encoded zero names the architectural zero GPR.","uimm24":"Encoded zero supplies numeric zero for the 24-bit unsigned immediate."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"SrcL","role":"left absolute GPR source"},{"field":"uimm24","role":"24-bit unsigned immediate"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.","After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-CMP-LTUI","mnemonic":"HL.CMP.LTUI","summary":"HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCompareResult_HL_CMP_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_LTUI(),
        left,
        right);
end;
// DOC-END: operation
