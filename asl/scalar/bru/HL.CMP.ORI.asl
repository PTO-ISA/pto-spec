// PTO-INSTRUCTION: {"assembly":["hl.cmp.ori SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[144],"catalog_records":[{"asm":"hl.cmp.ori SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00003055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_cmp_ori_48_4167568cb50b","length_bits":48,"mnemonic":"HL.CMP.ORI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","semantic_summary":"HL.CMP.ORI - Combine scalar comparison results with the encoded logical operation.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.cmp.ori SrcL, simm, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.cmp.ori SrcL, simm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SrcL":"Encoded zero names the architectural zero GPR.","simm24":"Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"SrcL","role":"left absolute GPR source"},{"field":"simm24","role":"24-bit signed immediate or displacement"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["HL.CMP.ORI - Combine scalar comparison results with the encoded logical operation.","After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-CMP-ORI","mnemonic":"HL.CMP.ORI","summary":"HL.CMP.ORI - Combine scalar comparison results with the encoded logical operation.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_HL_CMP_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCompareLogicalValue_HL_CMP_ORI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_HL_CMP_ORI() then
        return left OR right;
    end;
    return left AND right;
end;
// DOC-END: operation
