// PTO-INSTRUCTION: {"assembly":["c.setc.tgt srcL"],"block":[],"catalog_indices":[45],"catalog_records":[{"asm":"c.setc.tgt srcL","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x001c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_setc_tgt_16_736be9cada01","length_bits":16,"mnemonic":"C.SETC.TGT","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"SetCommitTarget","semantic_summary":"Snapshot one scalar source value into the active block BARG.BPCN.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["Applicable inside one active Standard or Floating block. The first successful occurrence owns the block target; a second occurrence is illegal."],"canonical_assembly":["c.setc.tgt srcL"],"defaults":["C.SETC.TGT has no omitted operand. SrcL code zero names the architectural zero GPR and snapshots numeric zero."],"encoding_class":"standalone-encoded","examples":["c.setc.tgt a0","c.setc.tgt T#1"],"exceptions":["No active Standard or Floating block, or a second successful C.SETC.TGT in the active block, raises Fault_BundleControl before source readiness or any state effect.","An unavailable relative source raises Fault_IllegalInstruction before changing BARG.BPCN, the uniqueness marker, TPC, or queue state.","An odd snapshotted target is accepted by C.SETC.TGT and raises Fault_InstructionPC only if the later block commit selects it."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["All SrcL codes 0..31 are assigned common scalar sources; relative sources are non-consuming and must be available when the instruction executes.","C.SETC.TGT is legal only while a Standard or Floating block is active. At most one C.SETC.TGT may complete successfully in that block.","Target alignment is not checked by C.SETC.TGT; the block commit boundary validates the final selected BARG.BPCN."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"common scalar source: absolute GPR, T#1..T#4, or U#1..U#4"}],"ordering":["Applicability and duplicate checks precede source readiness and source read. Source readiness precedes the BARG.BPCN update.","Later changes to the source register or queue cannot alter the pending target."],"standalone_opcode":true,"state_effects":["Read and snapshot the complete selected 64-bit source, then atomically replace active BARG.BPCN with that value.","Set the block-private successful-C.SETC.TGT marker only after the target snapshot succeeds. Do not retain the selector and do not modify the generic commit-condition argument."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SETC-TGT","mnemonic":"C.SETC.TGT","summary":"Snapshot one scalar source value into the active block BARG.BPCN.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETC_TGT() => ScalarOperation
begin
    return ScalarOperation_C_SETC_TGT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETC_TGT() => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

readonly func InstructionContractTarget_C_SETC_TGT(
    source_value: Word)
    => Word
begin
    return source_value;
end;
// DOC-END: operation
