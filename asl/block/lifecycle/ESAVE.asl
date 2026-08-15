// PTO-INSTRUCTION: {"assembly":["ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]"],"block":[],"catalog_indices":[61],"catalog_records":[{"asm":"ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]","constraints":[],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00002031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"esave_32_4c4f79fe3171","length_bits":32,"mnemonic":"ESAVE","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"SaveExecutionContext","semantic_summary":"Inventories an extension-owned execution-context save family rejected by PTO before operand interpretation or effects.","status":"reserved-in-pto"}],"classification":["lifecycle"],"contract":{"block_composition":["none; ESAVE is not an executable PTO command"],"canonical_assembly":["ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]"],"defaults":["No PTO default exists because the complete raw family is reserved and rejected before field interpretation."],"encoding_class":"standalone-encoded","examples":["ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)"],"exceptions":["Every matching form raises Fault_IllegalInstruction at the current TPC before register reads, memory access, context save, or state changes."],"field_contracts":{},"field_zero_meanings":{"RegSrc0":"Uninterpreted in PTO, including encoded zero.","RegSrc1":"Uninterpreted in PTO, including encoded zero.","RegSrc2":"Uninterpreted in PTO, including encoded zero."},"legality":["The full family selected by mask 0x06007fff and match 0x00002031 is occupied extension space and is not executable in PTO.","All 32 values of each encoded selector remain collision-protected and PTO must not allocate another instruction in this family."],"memory_effects":["none; rejection precedes every memory access"],"operands":[{"field":"RegSrc0","role":"uninterpreted extension field reserved in PTO"},{"field":"RegSrc1","role":"uninterpreted extension field reserved in PTO"},{"field":"RegSrc2","role":"uninterpreted extension field reserved in PTO"}],"ordering":["Decode and profile rejection precede operand interpretation and every architectural effect."],"standalone_opcode":true,"state_effects":["none; the form always raises Fault_IllegalInstruction before effects in PTO"]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-ESAVE","mnemonic":"ESAVE","summary":"Inventories an extension-owned execution-context save family rejected by PTO before effects.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BLOCK-ESAVE-RESERVED-001
// ndf: kind=contract level=L1 layer=block status=accepted
// PTO MUST reserve every ESAVE selector combination. A matching form MUST
// raise Fault_IllegalInstruction before reading any register or changing
// memory-command, trap-context, execution-context, or TPC state.
// NDF-END: PTO-BLOCK-ESAVE-RESERVED-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_esave_32_4c4f79fe3171;
end;

pure func InstructionContractSupported_ESAVE() => boolean
begin
    return FALSE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;

pure func InstructionContractRejectsBeforeEffects_ESAVE() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_SaveExecutionContext);
end;
// DOC-END: operation
