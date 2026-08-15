// PTO-INSTRUCTION: {"assembly":["lhui [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[340],"catalog_records":[{"agu":{"action":"Load","address_kind":"Immediate","offset_scale":1,"prefetch_returns_address":false,"signed_load":false,"size_bytes":2,"update_mode":"None"},"asm":"lhui [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005019","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"lhui_32_6da39bba900b","length_bits":32,"mnemonic":"LHUI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","semantic_summary":"LHUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["lhui [SrcL, simm], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["lhui [SrcL, simm], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","simm12":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 2.","Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst","role":"Reg5 loaded-value destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"simm12","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm12, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.","After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LHUI","mnemonic":"LHUI","summary":"LHUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LHUI() => ScalarOperation
begin
    return ScalarOperation_LHUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LHUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHUI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHUI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_LHUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHUI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
