// PTO-INSTRUCTION: {"assembly":["hl.lbu.pcr [<symbol>], ->{t, u, Rd}"],"block":[],"catalog_indices":[149],"catalog_records":[{"agu":{"action":"Load","address_kind":"PCRelative","offset_scale":2,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"hl.lbu.pcr [<symbol>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00004039000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}],"signedness":"signed","width":29}],"form_id":"hl_lbu_pcr_48_504b34c0ec9d","length_bits":48,"mnemonic":"HL.LBU.PCR","semantic_family":"AGU","semantic_group":"LDA/PC_REL","semantic_handler":"ExecuteScalarLoad","semantic_summary":"HL.LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.lbu.pcr [<symbol>], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["hl.lbu.pcr [<symbol>], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","simm":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.","Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst","role":"Reg5 loaded-value destination or discard"},{"field":"simm","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.","After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LBU-PCR","mnemonic":"HL.LBU.PCR","summary":"HL.LBU.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LBU_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LBU_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LBU_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LBU_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LBU_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LBU_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LBU_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LBU_PCR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
