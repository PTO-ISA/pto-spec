// PTO-INSTRUCTION: {"assembly":["setc.ori SrcL, simm"],"block":[],"catalog_indices":[413],"catalog_records":[{"asm":"setc.ori SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_ori_32_183dc15fad54","length_bits":32,"mnemonic":"SETC.ORI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","semantic_summary":"SETC.ORI - Combine scalar comparison results and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block."],"canonical_assembly":["setc.ori SrcL, simm"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["setc.ori SrcL, simm"],"exceptions":["Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.","A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","shamt":"Encoded zero performs no shift.","simm12":"Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement."},"legality":["All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"shamt","role":"shift amount"},{"field":"simm12","role":"12-bit signed immediate or displacement"}],"ordering":["Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.","Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker."],"standalone_opcode":true,"state_effects":["Compute SETC.ORI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.","Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.","No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SETC-ORI","mnemonic":"SETC.ORI","summary":"SETC.ORI - Combine scalar comparison results and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SETC-ORI-CONDITIONAL-SETTER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// SETC.ORI MUST be applicable only in one active Conditional block.
// Across all SETC condition setters, only the first successful occurrence in
// that block may snapshot sources and atomically update CommitArgument and
// BARG.TAKEN. A rejected occurrence MUST NOT consume the shared marker.
// NDF-END: PTO-SETC-ORI-CONDITIONAL-SETTER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_ORI() => ScalarOperation
begin
    return ScalarOperation_SETC_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCommitLogicalValue_SETC_ORI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_ORI() then
        return left OR right;
    end;
    return left AND right;
end;
// DOC-END: operation
