// PTO-INSTRUCTION: {"assembly":["lsrget LSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[346],"catalog_records":[{"asm":"lsrget LSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x000ff07f","match":"0x0000303b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"LSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"lsrget_32_448b17d7c20a","length_bits":32,"mnemonic":"LSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteLocalStateRegisterGet","semantic_summary":"LSRGET reads one assigned word from the active block BARG view.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["LSRGET is legal in any active block body for which the selected BARG word exists."],"canonical_assembly":["lsrget LSR_ID, ->{t, u, Rd}"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["lsrget LSR_ID, ->{t, u, Rd}"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","An unassigned or block-inapplicable BARG word raises Illegal Block Exception before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"LSR_ID":"Encoded zero selects BARG.BPC; it is not omission.","RegDst":"Encoded zero names the architectural zero GPR."},"legality":["IDs 0, 1, and 2 select BPC, BPCN, and the packed BARG control word; IDs 3 through 4095 are reserved.","ID 1 is applicable only to Standard and Floating blocks because other block types have no selecting BPCN."],"memory_effects":["none"],"operands":[{"field":"LSR_ID","role":"active BARG word identifier"},{"field":"RegDst","role":"Reg5 destination: discard, R1..R23, push U, or push T"}],"ordering":["Check active-body placement, ID assignment, and selected-word applicability before any destination or queue effect.","Snapshot the BARG word, publish it through RegDst, and then advance TPC."],"standalone_opcode":true,"state_effects":["ID 0 returns BARG.BPC; ID 1 returns BARG.BPCN; ID 2 returns the canonical packed control word.","The packed word contains BlockType, applicable TYPE and TAKEN, atomic, acquire, release, far, and dimension-reduction fields, with all higher bits zero.","LSRGET does not modify BARG or the system-register file."]},"depends_on":["PTO-BLOCK-MODEL-STATE-BARG"],"id":"PTO-SCALAR-LSRGET","mnemonic":"LSRGET","summary":"LSRGET reads one assigned word from the active block BARG view.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LSRGET()
    => ScalarOperation
begin
    return ScalarOperation_LSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteLocalStateRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_LSRGET()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractLocalRegisterIDLegal_LSRGET(
    identifier: bits(12)) => boolean
begin
    return UInt(identifier) <= 2;
end;

pure func InstructionContractBPCNApplicable_LSRGET(
    kind: BundleKind) => boolean
begin
    return kind == BundleKind_Standard ||
           kind == BundleKind_Floating;
end;

pure func InstructionContractReadsBARG_LSRGET()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
