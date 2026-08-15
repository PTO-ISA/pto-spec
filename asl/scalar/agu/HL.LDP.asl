// PTO-INSTRUCTION: {"assembly":["hl.ldp [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"block":[],"catalog_indices":[176],"catalog_records":[{"agu":{"action":"LoadPair","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":8,"update_mode":"None"},"asm":"hl.ldp [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x00003009001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_ldp_48_a7a45a43dff9","length_bits":48,"mnemonic":"HL.LDP","semantic_family":"AGU","semantic_group":"LDA/PAIR","semantic_handler":"ExecuteScalarLoadPair","semantic_summary":"HL.LDP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 8-byte values.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.ldp [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 negates the full PTO_XLEN value. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["hl.ldp [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards this result without suppressing the instruction's other effects.","RegDst1":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero leaves the complete PTO_XLEN register-offset value unchanged.","shamt":"Encoded zero performs no shift."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit."],"memory_effects":["Preflight both adjacent 8-byte addresses before either load; on success record two relaxed load events in address order."],"operands":[{"field":"RegDst0","role":"Reg5 first loaded-value destination or discard"},{"field":"RegDst1","role":"Reg5 second loaded-value destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.","The pair addresses are address and address plus 8; the instruction performs no base writeback.","After both 8-byte probes succeed, preserve each result at PTO_XLEN and publish first then second.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LDP","mnemonic":"HL.LDP","summary":"HL.LDP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 8-byte values.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LDP() => ScalarOperation
begin
    return ScalarOperation_HL_LDP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LDP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LDP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LDP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LDP()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LDP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDP()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
