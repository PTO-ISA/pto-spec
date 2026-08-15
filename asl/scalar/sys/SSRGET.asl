// PTO-INSTRUCTION: {"assembly":["ssrget SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[441],"catalog_records":[{"asm":"ssrget SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x000ff07f","match":"0x0000003b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12}],"form_id":"ssrget_32_959957ab6b75","length_bits":32,"mnemonic":"SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterGet","semantic_summary":"SSRGET reads the complete encoded system-register address.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["SSRGET executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["ssrget SSR_ID, ->{t, u, Rd}"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["ssrget SSR_ID, ->{t, u, Rd}"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero names the architectural zero GPR.","SSR_ID":"Encoded zero selects value zero of the system-register identifier."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects."],"memory_effects":["none"],"operands":[{"field":"RegDst","role":"Reg5 destination: discard, R1..R23, push U, or push T"},{"field":"SSR_ID","role":"system-register identifier"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Read the complete XLEN system-register value and publish it through the common Reg5 destination mapping.","A rejected read preserves the destination and queue state except for ordinary trap entry."]},"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS"],"id":"PTO-SCALAR-SSRGET","mnemonic":"SSRGET","summary":"SSRGET reads the complete encoded system-register address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_SSRGET()
    => integer {5,12,24}
begin
    return 12;
end;

pure func InstructionContractPushesTemporaryT_SSRGET()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
