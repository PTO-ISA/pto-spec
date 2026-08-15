// PTO-INSTRUCTION: {"assembly":["c.swi t#1, [srcL, simm]"],"block":[],"catalog_indices":[54],"catalog_records":[{"agu":{"action":"Store","address_kind":"Compressed","offset_scale":2,"prefetch_returns_address":false,"signed_load":false,"size_bytes":4,"update_mode":"None"},"asm":"c.swi t#1, [srcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x002a","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_swi_16_ca6c111163e5","length_bits":16,"mnemonic":"C.SWI","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","semantic_summary":"C.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["c.swi t#1, [srcL, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["c.swi t#1, [srcL, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","simm5":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.","simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 4.","Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"SrcL","role":"Reg5 address-base source"},{"field":"simm5","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm5, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.","Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.","Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SWI","mnemonic":"C.SWI","summary":"C.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_C_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_C_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SWI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
