// PTO-INSTRUCTION: {"assembly":["BSTART DIRECT, <label>","BSTART COND, <label>"],"block":[],"catalog_indices":[13,14],"catalog_records":[{"asm":"BSTART DIRECT, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000011","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25}],"form_id":"bstart_32_7eb93b649748","length_bits":32,"mnemonic":"BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Initializes the single BARG continuation record after any retiring block commits successfully.","status":"accepted"},{"asm":"BSTART COND, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000021","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25}],"form_id":"bstart_32_e11e678a32ac","length_bits":32,"mnemonic":"BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Initializes the single BARG continuation record after any retiring block commits successfully.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["BSTART DIRECT, <label>","BSTART COND, <label>"],"defaults":["simm25 zero is a real zero displacement, so BARG.BPCN equals the BSTART address P."],"encoding_class":"standalone-encoded","examples":["BSTART DIRECT, <label>"],"exceptions":["An odd computed BARG.BPCN raises Fault_InstructionPC before changing BARG.","A failed retiring-block commit preserves the retiring BARG and does not install the candidate BARG."],"field_contracts":{},"field_zero_meanings":{"simm25":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["The low-seven-bit 0010001 form is DIRECT only; CALL is not an alias.","The low-seven-bit 0100001 form is COND only."],"memory_effects":["Any memory effects of the retiring block complete before the new BARG is installed; BSTART itself performs no memory access."],"operands":[{"field":"simm25","role":"25-bit signed bundle target displacement"}],"ordering":["Decode and candidate-target validation precede retiring-block commit; successful commit precedes atomic publication of the new BARG."],"standalone_opcode":true,"state_effects":["DIRECT installs BARG.BPC=P, BlockType=STD, BPCN=P+(SignExtend(simm25)<<1), TYPE=DIRECT, TAKEN=1.","COND installs the same BPC/BlockType/BPCN fields with TYPE=COND and TAKEN=0; SETC.* may update TAKEN and SETC.TGT may update BPCN before commit.","Neither form selects BPCN at decode; BSTOP or the next BSTART is the continuation boundary."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART","mnemonic":"BSTART","summary":"Initializes the single BARG continuation record after any retiring block commits successfully.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
