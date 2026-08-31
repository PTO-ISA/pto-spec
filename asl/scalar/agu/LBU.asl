// PTO-INSTRUCTION: {"assembly":["lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}"],"block":[],"catalog_indices":[311],"catalog_records":[{"agu":{"action":"Load","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004009","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"lbu_32_a9a58ab4ea22","length_bits":32,"mnemonic":"LBU","semantic_family":"AGU","semantic_group":"LDA/BASE_REG","semantic_handler":"ExecuteScalarLoad","semantic_summary":"LBU snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier.","shamt":"Encoded zero performs no shift."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst","role":"Reg5 loaded-value destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.","After a successful 1-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LBU","mnemonic":"LBU","summary":"LBU snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LBU() => ScalarOperation
begin
    return ScalarOperation_LBU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LBU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LBU()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LBU()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_LBU()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_LBU()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_LBU()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LBU()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LBU()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
