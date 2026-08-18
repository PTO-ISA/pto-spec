// PTO-INSTRUCTION: {"assembly":["setc.tgt SrcL"],"block":[],"catalog_indices":[414],"catalog_records":[{"asm":"setc.tgt SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000403b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"setc_tgt_32_c02656d3a2b8","length_bits":32,"mnemonic":"SETC.TGT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SetCommitTarget","semantic_summary":"SETC.TGT snapshots SrcL into BARG.BPCN for the active Standard or Floating block.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["SETC.TGT is legal in the body of an active Standard or Floating block and is not a SYS-block instruction."],"canonical_assembly":["setc.tgt SrcL"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["setc.tgt SrcL"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names the architectural zero GPR."},"legality":["Every available Reg5 source selector is assigned; block applicability is checked before the source read."],"memory_effects":["none"],"operands":[{"field":"SrcL","role":"Reg5 source: R0..R23, T#1..T#4, or U#1..U#4"}],"ordering":["Check block applicability, snapshot SrcL, write BARG.BPCN, and then advance TPC."],"standalone_opcode":true,"state_effects":["Replace only BARG.BPCN with the complete XLEN source; preserve BPC, BlockType, TYPE, TAKEN, and all other block state."]},"depends_on":["PTO-BLOCK-MODEL-STATE-BARG"],"id":"PTO-SCALAR-SETC-TGT","mnemonic":"SETC.TGT","summary":"SETC.TGT snapshots SrcL into BARG.BPCN for the active Standard or Floating block.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SETC-TGT-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0026.
// SETC.TGT MUST snapshot its complete scalar source into the applicable
// active block BARG.BPCN only after placement and source readiness checks.
// Rejection MUST preserve the prior target and pending-block state.
// NDF-END: PTO-SETC-TGT-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_TGT()
    => ScalarOperation
begin
    return ScalarOperation_SETC_TGT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_TGT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

pure func InstructionContractRequiresSystemBlock_SETC_TGT()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractRequiresCommitTargetBlock_SETC_TGT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesBARGBPCN_SETC_TGT()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
