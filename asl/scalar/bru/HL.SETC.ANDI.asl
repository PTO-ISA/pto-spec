// PTO-INSTRUCTION: {"assembly":["hl.setc.andi SrcL, simm"],"block":[],"catalog_indices":[259],"catalog_records":[{"asm":"hl.setc.andi SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00002075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_setc_andi_48_f27796612fb3","length_bits":48,"mnemonic":"HL.SETC.ANDI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","semantic_summary":"HL.SETC.ANDI - Combine scalar comparison results and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block."],"canonical_assembly":["hl.setc.andi SrcL, simm"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["hl.setc.andi SrcL, simm"],"exceptions":["Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.","A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","shamt":"Encoded zero performs no shift.","simm24":"Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement."},"legality":["All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"shamt","role":"shift amount"},{"field":"simm24","role":"24-bit signed immediate or displacement"}],"ordering":["Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.","Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker."],"standalone_opcode":true,"state_effects":["Compute HL.SETC.ANDI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.","Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.","No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SETC-ANDI","mnemonic":"HL.SETC.ANDI","summary":"HL.SETC.ANDI - Combine scalar comparison results and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-SETC-ANDI-CONDITIONAL-SETTER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.SETC.ANDI MUST be applicable only in one active Conditional block.
// Across all SETC condition setters, only the first successful occurrence in
// that block may snapshot sources and atomically update CommitArgument and
// BARG.TAKEN. A rejected occurrence MUST NOT consume the shared marker.
// NDF-END: PTO-HL-SETC-ANDI-CONDITIONAL-SETTER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_HL_SETC_ANDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_HL_SETC_ANDI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_HL_SETC_ANDI() then
        return left OR right;
    end;
    return left AND right;
end;
// DOC-END: operation
