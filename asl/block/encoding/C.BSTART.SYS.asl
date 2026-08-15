// PTO-INSTRUCTION: {"assembly":["C.BSTART.SYS FALL"],"block":[],"catalog_indices":[58],"catalog_records":[{"asm":"C.BSTART.SYS FALL","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x0840","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstart_sys_16_ec213ce96eb7","length_bits":16,"mnemonic":"C.BSTART.SYS","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts the fixed compressed sequential System block without a selecting branch continuation.","status":"accepted"}],"classification":["encoding"],"contract":{"block_composition":["After any active predecessor block commits successfully, C.BSTART.SYS opens one System block. Its header commands execute sequentially until BSTOP or the next BSTART."],"canonical_assembly":["C.BSTART.SYS FALL"],"defaults":["The instruction has no operand field. FALL and zero displacement are fixed by its complete 16-bit encoding."],"encoding_class":"standalone-encoded","examples":["C.BSTART.SYS FALL"],"exceptions":["Any different bit pattern belongs to another instruction or is illegal; it is not a C.BSTART.SYS operand variation.","If predecessor commit fails, the retiring block remains authoritative and no System BARG is installed."],"field_contracts":{},"field_zero_meanings":{},"legality":["The complete 16-bit pattern 0x0840 is the only accepted C.BSTART.SYS encoding.","System blocks have only sequential fallthrough and expose no BPCN, TYPE, or TAKEN continuation."],"memory_effects":["none"],"operands":[],"ordering":["The predecessor block commits before the new System BARG is installed. C.BSTART.SYS itself performs no memory access."],"standalone_opcode":true,"state_effects":["Installs BARG.BPC=P and BlockType=SYS, advances header execution to P+2, and keeps BPCN zero with canonical non-selecting fallthrough state.","BSTOP or the next BSTART commits to the sequential continuation."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-C-BSTART-SYS","mnemonic":"C.BSTART.SYS","summary":"Starts the fixed compressed sequential System block without a selecting branch continuation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-BSTART-SYS-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// C.BSTART.SYS MUST open the unique compressed sequential system block. It
// MUST NOT install a selecting BPCN, TYPE, or TAKEN continuation field.
// NDF-END: PTO-C-BSTART-SYS-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_sys_16_ec213ce96eb7);
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractKind_C_BSTART_SYS() => BundleKind
begin
    return BundleKind_System;
end;

readonly func InstructionContractHandler_C_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
