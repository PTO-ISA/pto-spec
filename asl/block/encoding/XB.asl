// PTO-INSTRUCTION: {"assembly":["XB ACR-ID, C-ID"],"block":[],"catalog_indices":[71],"catalog_records":[{"asm":"XB ACR-ID, C-ID","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00006f81","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"ACR-ID","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":10}],"signedness":"encoding-defined","width":10},{"name":"CROSS-BID","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"xb_32_40ad190a0a7f","length_bits":32,"mnemonic":"XB","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteCrossBlockTransfer","semantic_summary":"Inventories an extension-owned cross-block transfer encoding that PTO rejects before field interpretation or architectural effects.","status":"reserved-in-pto"}],"classification":["encoding"],"contract":{"block_composition":["none; XB is not an executable PTO block command"],"canonical_assembly":["XB ACR-ID, C-ID"],"defaults":["No PTO default exists because the complete form is reserved and rejected before ACR-ID or CROSS-BID interpretation."],"encoding_class":"standalone-encoded","examples":["XB ACR-ID, C-ID (reserved in PTO)"],"exceptions":["Every matching 32-bit form raises Fault_IllegalInstruction at the current TPC before ACR-ID or CROSS-BID is interpreted and before command, block, memory, or control-flow state changes."],"field_contracts":{},"field_zero_meanings":{"ACR-ID":"Uninterpreted in PTO, including encoded zero.","CROSS-BID":"Uninterpreted in PTO, including encoded zero."},"legality":["The full family selected by mask 0x00007fff and match 0x00006f81 is occupied extension space and is not executable in PTO.","All 1024 ACR-ID values and all 128 CROSS-BID values remain collision-protected; PTO must not allocate another instruction anywhere in this raw family.","Decode retains the form identity only for collision inventory and fail-closed dispatch. CommandHandlerSupportedPTOv0 returns false for ExecuteCrossBlockTransfer."],"memory_effects":["none; rejection precedes every memory access"],"operands":[{"field":"ACR-ID","role":"uninterpreted extension field reserved in PTO"},{"field":"CROSS-BID","role":"uninterpreted extension field reserved in PTO"}],"ordering":["Decode and profile rejection precede operand interpretation and every architectural effect."],"standalone_opcode":true,"state_effects":["none; the form always raises Fault_IllegalInstruction before effects in PTO"]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-XB","mnemonic":"XB","summary":"Inventories an extension-owned cross-block transfer encoding that PTO rejects before field interpretation or architectural effects.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BLOCK-XB-RESERVED-001
// ndf: kind=contract level=L1 layer=block status=accepted
// PTO MUST reserve the complete XB raw encoding family. Every matching form
// MUST raise Fault_IllegalInstruction before decoding an operand value or
// changing command, block, memory, cross-block, or control-flow state.
// NDF-END: PTO-BLOCK-XB-RESERVED-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_XB(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_xb_32_40ad190a0a7f;
end;

pure func InstructionContractSupported_XB() => boolean
begin
    return FALSE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_XB() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteCrossBlockTransfer;
end;

pure func InstructionContractRejectsBeforeEffects_XB() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_ExecuteCrossBlockTransfer);
end;
// DOC-END: operation
