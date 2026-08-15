// PTO-INSTRUCTION: {"assembly":["lw.pcr [symbol], ->{t, u, Rd}"],"block":[],"catalog_indices":[352],"catalog_records":[{"agu":{"action":"Load","address_kind":"PCRelative","offset_scale":2,"prefetch_returns_address":false,"signed_load":true,"size_bytes":4,"update_mode":"None"},"asm":"lw.pcr [symbol], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002039","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"lw_pcr_32_d135a1aa4ffb","length_bits":32,"mnemonic":"LW.PCR","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ExecuteScalarLoad","semantic_summary":"LW.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["lw.pcr [symbol], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["lw.pcr [symbol], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","simm17":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.","Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 4-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst","role":"Reg5 loaded-value destination or discard"},{"field":"simm17","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.","After a successful 4-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LW-PCR","mnemonic":"LW.PCR","summary":"LW.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 4-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LW_PCR() => ScalarOperation
begin
    return ScalarOperation_LW_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LW_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LW_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LW_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LW_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_LW_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LW_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LW_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LW_PCR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
