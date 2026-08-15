// PTO-INSTRUCTION: {"assembly":["hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}"],"block":[],"catalog_indices":[299],"catalog_records":[{"agu":{"action":"Store","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":4,"update_mode":"PreIndex"},"asm":"hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff07ff","match":"0x00006049002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sw_upr_48_d4ccb513944a","length_bits":48,"mnemonic":"HL.SW.UPR","semantic_family":"AGU","semantic_group":"STA/PRE_INDEX","semantic_handler":"ExecuteScalarStore","semantic_summary":"HL.SW.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 negates the full PTO_XLEN value. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["hl.sw.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcD":"Encoded zero reads the architectural zero GPR.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero leaves the complete PTO_XLEN register-offset value unchanged."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"RegDst","role":"Reg5 updated-base destination or discard"},{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.","Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SW-UPR","mnemonic":"HL.SW.UPR","summary":"HL.SW.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SW_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SW_UPR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SW_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SW_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SW_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SW_UPR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SW_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SW_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SW_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SW_UPR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
