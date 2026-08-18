// PTO-INSTRUCTION: {"assembly":["cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}"],"block":[],"catalog_indices":[69],"catalog_records":[{"asm":"cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x00003045","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"cmp_or_32_75e1fa54ba94","length_bits":32,"mnemonic":"CMP.OR","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","semantic_summary":"CMP.OR - Combine scalar comparison results with the encoded logical operation.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SrcL":"Encoded zero names the architectural zero GPR.","SrcR":"Encoded zero names the architectural zero GPR.","SrcRType":"Encoded zero selects value zero of the right-source modifier selector."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"absolute GPR destination"},{"field":"SrcL","role":"left absolute GPR source"},{"field":"SrcR","role":"right absolute GPR source"},{"field":"SrcRType","role":"right-source modifier selector"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["CMP.OR - Combine scalar comparison results with the encoded logical operation.","After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-CMP-OR","mnemonic":"CMP.OR","summary":"CMP.OR - Combine scalar comparison results with the encoded logical operation.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_OR() => ScalarOperation
begin
    return ScalarOperation_CMP_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_CMP_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCompareLogicalValue_CMP_OR(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_CMP_OR() then
        return left OR right;
    end;
    return left AND right;
end;
// DOC-END: operation
