// PTO-INSTRUCTION: {"assembly":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"block":[],"catalog_indices":[398],"catalog_records":[{"asm":"setc.and SrcL, SrcR<.sw, .uw, .not>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00002065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_and_32_90b4e93ef9d4","length_bits":32,"mnemonic":"SETC.AND","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","semantic_summary":"SETC.AND - Combine scalar comparison results and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block."],"canonical_assembly":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"exceptions":["Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.","A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","SrcR":"Encoded zero names the architectural zero GPR.","SrcRType":"Encoded zero selects value zero of the right-source modifier selector."},"legality":["All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"SrcR","role":"right absolute GPR source"},{"field":"SrcRType","role":"right-source modifier selector"}],"ordering":["Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.","Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker."],"standalone_opcode":true,"state_effects":["Compute SETC.AND's local comparison or logical condition from source snapshots and canonicalize it to zero or one.","Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.","No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SETC-AND","mnemonic":"SETC.AND","summary":"SETC.AND - Combine scalar comparison results and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SETC-AND-CONDITIONAL-SETTER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// SETC.AND MUST be applicable only in one active Conditional block.
// Across all SETC condition setters, only the first successful occurrence in
// that block may snapshot sources and atomically update CommitArgument and
// BARG.TAKEN. A rejected occurrence MUST NOT consume the shared marker.
// NDF-END: PTO-SETC-AND-CONDITIONAL-SETTER-001
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
