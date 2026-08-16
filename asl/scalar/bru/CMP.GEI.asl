// PTO-INSTRUCTION: {"assembly":["cmp.gei SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[68],"catalog_records":[{"asm":"cmp.gei SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005055","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"cmp_gei_32_48bf7ea50737","length_bits":32,"mnemonic":"CMP.GEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","semantic_summary":"CMP.GEI - Compare scalar operands and write the encoded boolean result.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["cmp.gei SrcL, simm, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["cmp.gei SrcL, simm, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SrcL":"Encoded zero names the architectural zero GPR.","simm12":"Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"SrcL","role":"left absolute GPR source"},{"field":"simm12","role":"12-bit signed immediate or displacement"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["CMP.GEI - Compare scalar operands and write the encoded boolean result.","After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-CMP-GEI","mnemonic":"CMP.GEI","summary":"CMP.GEI - Compare scalar operands and write the encoded boolean result.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_CMP_GEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_GEI()
    => ScalarCondition
begin
    return ScalarCondition_GE;
end;

pure func InstructionContractCompareResult_CMP_GEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_GEI(),
        left,
        right);
end;
// DOC-END: operation
