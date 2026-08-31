// PTO-INSTRUCTION: {"assembly":["B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}","B.HINT TRACE.{begin, end}"],"block":[],"catalog_indices":[5,6],"catalog_records":[{"asm":"B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}","constraints":[],"encoding":[{"index":0,"mask":"0x00087fff","match":"0x00000033","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"L/UL","pieces":[{"instruction_lsb":16,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"V","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"prefetch_size","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"temp","pieces":[{"instruction_lsb":17,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"b_hint_32_69d942ff1583","length_bits":32,"mnemonic":"B.HINT","semantic_family":"CMD","semantic_group":"Bundle Hint","semantic_handler":"SetBundleHint","semantic_summary":"Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.","status":"accepted"},{"asm":"B.HINT TRACE.{begin, end}","constraints":[],"encoding":[{"index":0,"mask":"0xffff7fff","match":"0x00001033","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"B/E","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"b_hint_32_f7d01d734925","length_bits":32,"mnemonic":"B.HINT","semantic_family":"CMD","semantic_group":"Bundle Hint","semantic_handler":"SetBundleHint","semantic_summary":"Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["Ordinary form: optional once after BSTART and before the block body.","TRACE form: acts as a block start only when predecessor commit selects the fetched TRACE PC, and an installed trace block must later be terminated by BSTOP or the next block start."],"canonical_assembly":["B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}","B.HINT TRACE.{begin, end}"],"defaults":["An ordinary block may omit B.HINT; omission supplies no branch, temperature, or prefetch guidance.","For the ordinary form V=0 disables branch guidance, L/UL=0 denotes unlikely/fallthrough, temp=0 denotes none, and prefetch_size=0 requests no cache-line prefetch.","For TRACE, B/E=0 denotes begin and B/E=1 denotes end."],"encoding_class":"standalone-encoded","examples":["B.HINT {BR.likely, TEMP.hot, 64}","B.HINT TRACE.begin"],"exceptions":["An ordinary B.HINT outside an active block header or a duplicate ordinary B.HINT raises Illegal Block Exception before hint state changes.","If TRACE cannot retire an active predecessor block, the predecessor fault is preserved and the trace block is not opened. If predecessor commit selects another PC, TRACE changes no hint or trace state."],"field_contracts":{},"field_zero_meanings":{"V":"branch hint invalid; implementation predicts normally","L/UL":"unlikely branch / likely fallthrough when V is one","temp":"none","prefetch_size":"no cache-line prefetch","B/E":"TRACE.begin"},"legality":["An ordinary B.HINT is legal only after BSTART and before the block body, and at most one B.HINT may belong to that block header.","A second ordinary B.HINT raises Illegal Block Exception before replacing the first hint.","B.HINT TRACE is a special block-start operation. It first retires any active predecessor block and opens a new empty fallthrough block only when the committed TPC equals the fetched TRACE PC."],"memory_effects":["none"],"operands":[{"field":"V","role":"branch-hint validity: 0 invalid, 1 valid"},{"field":"L/UL","role":"when V=1, 0 unlikely/fallthrough and 1 likely/taken"},{"field":"temp","role":"temperature: 0 none, 1 cool, 2 warm, 3 hot"},{"field":"prefetch_size","role":"number of cache lines to prefetch beginning with the cache line containing the current block instruction"},{"field":"B/E","role":"trace boundary: 0 begin, 1 end"}],"ordering":["Ordinary hints update the active header in place. TRACE first commits any active predecessor, verifies that its selected TPC is the fetched TRACE PC, and only then installs and records the empty trace block."],"standalone_opcode":true,"state_effects":["Decode and retain the selected hint fields as pending state of the active block and increment the non-functional hint epoch.","TRACE.begin or TRACE.end opens an empty block and records its boundary kind only at a predecessor-selected boundary; skipped TRACE changes no hint state. An installed TRACE does not complete its new block."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-B-HINT","mnemonic":"B.HINT","summary":"Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-HINT-LIFECYCLE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// An ordinary B.HINT MUST occur at most once in an active block header and
// MUST NOT change functional results. B.HINT TRACE MUST begin an empty block
// only when predecessor commit selects the fetched TRACE PC; otherwise TRACE
// MUST preserve the selected TPC and MUST NOT change hint state. An installed
// trace block MUST remain active until BSTOP or a following block start.
// NDF-END: PTO-B-HINT-LIFECYCLE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_HINT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_hint_32_69d942ff1583) ||
           (operation == CommandOperation_b_hint_32_f7d01d734925);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;

pure func InstructionContractIsBundleHint_B_HINT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTraceFormMayTerminate_B_HINT()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
