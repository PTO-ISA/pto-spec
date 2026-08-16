// PTO-INSTRUCTION: {"assembly":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"block":[],"catalog_indices":[406],"catalog_records":[{"asm":"setc.and SrcL, SrcR<.sw, .uw, .not>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00002065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_and_32_90b4e93ef9d4","length_bits":32,"mnemonic":"SETC.AND","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","semantic_summary":"SETC.AND - Combine scalar comparison results and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["none"],"canonical_assembly":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"exceptions":["Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","SrcR":"Encoded zero names the architectural zero GPR.","SrcRType":"Encoded zero selects value zero of the right-source modifier selector."},"legality":["Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"SrcR","role":"right absolute GPR source"},{"field":"SrcRType","role":"right-source modifier selector"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["SETC.AND - Combine scalar comparison results and update the bundle commit condition.","After decode and legality checks, execute the normative ExecuteSetCommitLogical ASL handler; no other architectural state is modified."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SETC-AND","mnemonic":"SETC.AND","summary":"SETC.AND - Combine scalar comparison results and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_AND()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_SETC_AND(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_AND() then
        return left OR right;
    end;
    return left AND right;
end;
// DOC-END: operation
