// PTO-INSTRUCTION: {"assembly":["BSTART.SYS FALL"],"block":[],"catalog_indices":[32],"catalog_records":[{"asm":"BSTART.SYS FALL","constraints":[{"field":"simm17","operator":"one-of","values":[0]}],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00001081","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"bstart_sys_32_762d9d84a6d8","length_bits":32,"mnemonic":"BSTART.SYS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.SYS retires any active predecessor block, then opens one system block whose header commands execute sequentially until BSTOP or the next BSTART.","SYS has no candidate transfer: BPCN, TYPE, and TAKEN are inapplicable and cannot select the next PC."],"canonical_assembly":["BSTART.SYS FALL"],"defaults":["The encoded simm17 field is fixed to zero; nonzero values are extension-reserved."],"encoding_class":"standalone-encoded","examples":["BSTART.SYS FALL"],"exceptions":["Any nonzero simm17 in the SYS FALL family is extension-reserved and raises before predecessor retirement or new BARG effects.","If predecessor commit fails, the old block and continuation remain authoritative and no system block is installed."],"field_contracts":{},"field_zero_meanings":{"simm17":"Encoded zero supplies a zero displacement or zero immediate value."},"legality":["Only simm17=0 is accepted; every nonzero payload is extension-reserved."],"memory_effects":["none"],"operands":[{"field":"simm17","role":"fixed-zero fallthrough payload; nonzero values are extension-reserved"}],"ordering":["The fixed-zero payload and form legality are checked before predecessor retirement. New SYS BARG state is installed only after successful retirement."],"standalone_opcode":true,"state_effects":["On success BPC records the BSTART address and BARG.BlockType becomes SYS. BPCN, TYPE, and TAKEN are inapplicable and are canonicalized to non-selecting values.","Header execution and the eventual block continuation are sequential."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-SYS","mnemonic":"BSTART.SYS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-SYS-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.SYS MUST accept only FALL with simm17=0, MUST publish BPC and SYS
// BlockType after successful predecessor retirement, and MUST treat BPCN,
// TYPE, and TAKEN as inapplicable non-selecting state.
// NDF-END: PTO-BSTART-SYS-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
