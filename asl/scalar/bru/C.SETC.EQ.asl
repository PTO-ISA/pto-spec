// PTO-INSTRUCTION: {"assembly":["c.setc.eq srcL, srcR"],"block":[],"catalog_indices":[35],"catalog_records":[{"asm":"c.setc.eq srcL, srcR","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0026","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_setc_eq_16_03e6b07a3699","length_bits":16,"mnemonic":"C.SETC.EQ","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","semantic_summary":"C.SETC.EQ - Compare scalar operands and update the bundle commit condition.","status":"accepted"}],"classification":["bru"],"contract":{"block_composition":["Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block."],"canonical_assembly":["c.setc.eq srcL, srcR"],"defaults":["The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission."],"encoding_class":"standalone-encoded","examples":["c.setc.eq srcL, srcR"],"exceptions":["Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.","A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR.","SrcR":"Encoded zero names the architectural zero GPR."},"legality":["All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"left absolute GPR source"},{"field":"SrcR","role":"right absolute GPR source"}],"ordering":["Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.","Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker."],"standalone_opcode":true,"state_effects":["Compute C.SETC.EQ's local comparison or logical condition from source snapshots and canonicalize it to zero or one.","Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.","No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SETC-EQ","mnemonic":"C.SETC.EQ","summary":"C.SETC.EQ - Compare scalar operands and update the bundle commit condition.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-SETC-EQ-CONDITIONAL-SETTER-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// C.SETC.EQ MUST be applicable only in one active Conditional block.
// Across all SETC condition setters, only the first successful occurrence in
// that block may snapshot sources and atomically update CommitArgument and
// BARG.TAKEN. A rejected occurrence MUST NOT consume the shared marker.
// NDF-END: PTO-C-SETC-EQ-CONDITIONAL-SETTER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_C_SETC_EQ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_C_SETC_EQ()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_C_SETC_EQ(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_SETC_EQ(),
        left,
        right);
end;
// DOC-END: operation
