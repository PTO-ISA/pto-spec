// PTO-INSTRUCTION: {"assembly":["BSTART.FP RET","BSTART.FP COND, <label>","BSTART.FP IND","BSTART.FP DIRECT, <label>","BSTART.FP FALL"],"block":[],"catalog_indices":[17,18,19,20,21],"catalog_records":[{"asm":"BSTART.FP RET","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x00007101","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bstart_fp_32_0c671a644214","length_bits":32,"mnemonic":"BSTART.FP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"BSTART.FP COND, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00003101","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"bstart_fp_32_58ad7954fb49","length_bits":32,"mnemonic":"BSTART.FP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"BSTART.FP IND","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x00005101","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bstart_fp_32_7978795a29a1","length_bits":32,"mnemonic":"BSTART.FP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"BSTART.FP DIRECT, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00002101","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"bstart_fp_32_d00a708a81f0","length_bits":32,"mnemonic":"BSTART.FP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"BSTART.FP FALL","constraints":[{"field":"simm17","operator":"one-of","values":[0]}],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00001101","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"bstart_fp_32_face4f238d84","length_bits":32,"mnemonic":"BSTART.FP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.FP retires any active predecessor block, then opens one FP block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.","COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement."],"canonical_assembly":["BSTART.FP RET","BSTART.FP COND, <label>","BSTART.FP IND","BSTART.FP DIRECT, <label>","BSTART.FP FALL"],"defaults":["BSTART.FP FALL encodes simm17=0; nonzero values in that family are extension-reserved."],"encoding_class":"standalone-encoded","examples":["BSTART.FP FALL","BSTART.FP DIRECT, target","BSTART.FP COND, target","BSTART.FP IND","BSTART.FP RET"],"exceptions":["A nonzero FALL simm17, deleted bare CALL/ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.","IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.","If predecessor commit fails, the old block and continuation remain authoritative and no FP block is installed."],"field_contracts":{},"field_zero_meanings":{"simm17":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["Exactly FALL, DIRECT, COND, IND, and RET are accepted.","The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.","Bare CALL and ICALL forms are deleted."],"memory_effects":["none"],"operands":[{"field":"simm17","role":"17-bit signed bundle target displacement"}],"ordering":["All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement."],"standalone_opcode":true,"state_effects":["On success BPC records the BSTART address; BARG.BlockType becomes FP; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.","Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-FP","mnemonic":"BSTART.FP","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-FP-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.FP MUST accept only FALL(0), DIRECT, COND, IND, and RET, MUST
// initialize one FP BARG after successful predecessor retirement, and MUST
// reject nonzero Fixup payloads and deleted bare call forms before effects.
// NDF-END: PTO-BSTART-FP-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_FP()
    => BundleKind
begin
    return BundleKind_Floating;
end;

pure func InstructionContractStartsBundle_BSTART_FP()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
