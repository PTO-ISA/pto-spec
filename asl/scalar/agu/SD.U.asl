// PTO-INSTRUCTION: {"assembly":["sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"block":[],"catalog_indices":[392],"catalog_records":[{"agu":{"action":"Store","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":8,"update_mode":"None"},"asm":"sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00007049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sd_u_32_1602c58c2031","length_bits":32,"mnemonic":"SD.U","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","semantic_summary":"SD.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SD-U","mnemonic":"SD.U","summary":"SD.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SD-U-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0024, ADR-0029.
// SD.U MUST snapshot scalar address/data sources, apply its mnemonic
// width and address-update mode, preflight access before effects, then commit
// the store event and any base update at the defined restart boundary.
// NDF-END: PTO-SD-U-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SD_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SD_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SD_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SD_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SD_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SD_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SD_U()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
