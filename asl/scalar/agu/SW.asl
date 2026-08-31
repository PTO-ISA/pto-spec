// PTO-INSTRUCTION: {"assembly":["sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]"],"block":[],"catalog_indices":[440],"catalog_records":[{"agu":{"action":"Store","address_kind":"Register","offset_scale":2,"prefetch_returns_address":false,"signed_load":false,"size_bytes":4,"update_mode":"None"},"asm":"sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00002049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sw_32_28ad317b1b41","length_bits":32,"mnemonic":"SW","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","semantic_summary":"SW snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SW","mnemonic":"SW","summary":"SW snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SW-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0024, ADR-0029.
// SW MUST snapshot scalar address/data sources, apply its mnemonic
// width and address-update mode, preflight access before effects, then commit
// the store event and any base update at the defined restart boundary.
// NDF-END: PTO-SW-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW() => ScalarOperation
begin
    return ScalarOperation_SW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
