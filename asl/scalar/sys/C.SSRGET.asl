// PTO-INSTRUCTION: {"assembly":["c.ssrget SSR-ID, ->t"],"block":[],"catalog_indices":[52],"catalog_records":[{"asm":"c.ssrget SSR-ID, ->t","constraints":[{"field":"SSRID","operator":"one-of","values":[0,1,16]}],"encoding":[{"index":0,"mask":"0xf83f","match":"0x802c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SSRID","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_ssrget_16_9d83a6f2749a","length_bits":16,"mnemonic":"C.SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteCompressedSystemRegisterGet","semantic_summary":"C.SSRGET reads the complete encoded system-register address.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["C.SSRGET executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["c.ssrget SSR-ID, ->t"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["c.ssrget SSR-ID, ->t"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"SSRID":"Encoded zero selects value zero of the short system-register identifier."},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics.","The complete encoded address is checked against its RO, WO, RW, unknown-address, and current-ACR access rules before effects.","Only direct IDs 0, 1, and 16 are assigned; every other five-bit ID is reserved."],"memory_effects":["none"],"operands":[{"field":"SSRID","role":"short system-register identifier"}],"ordering":["Check block placement and encoded legality before source reads or architectural effects.","Snapshot every scalar source before the selected system effect, then advance TPC only after success."],"standalone_opcode":true,"state_effects":["Read THREAD_PTR, GLOBAL_PTR, or TIME for direct IDs 0, 1, or 16 and push the complete XLEN value to T.","A rejected access preserves T queue order and contents except for ordinary trap entry."]},"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS"],"id":"PTO-SCALAR-C-SSRGET","mnemonic":"C.SSRGET","summary":"C.SSRGET reads the complete encoded system-register address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SSRGET()
    => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSystemTransferKind_C_SSRGET()
    => bits(2)
begin
    return '00';
end;

pure func InstructionContractSystemAddressWidth_C_SSRGET()
    => integer {5,12,24}
begin
    return 5;
end;

pure func InstructionContractPushesTemporaryT_C_SSRGET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDirectSystemIDLegal_C_SSRGET(
    identifier: bits(5)) => boolean
begin
    return identifier == '00000' ||
           identifier == '00001' ||
           identifier == '10000';
end;
// DOC-END: operation
