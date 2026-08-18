// PTO-INSTRUCTION: {"assembly":["swi SrcL, [SrcR, simm]"],"block":[],"catalog_indices":[455],"catalog_records":[{"agu":{"action":"Store","address_kind":"Immediate","offset_scale":2,"prefetch_returns_address":false,"signed_load":false,"size_bytes":4,"update_mode":"None"},"asm":"swi SrcL, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002059","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"swi_32_147e55489c41","length_bits":32,"mnemonic":"SWI","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","semantic_summary":"SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["swi SrcL, [SrcR, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["swi SrcL, [SrcR, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","simm12":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 4.","Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"SrcL","role":"Reg5 store-data source"},{"field":"SrcR","role":"Reg5 address-base source"},{"field":"simm12","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm12, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcR base.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SWI","mnemonic":"SWI","summary":"SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-SWI-ADR-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Decisions: ADR-0024, ADR-0029.
// SWI MUST snapshot scalar address/data sources, apply its mnemonic
// width and address-update mode, preflight access before effects, then commit
// the store event and any base update at the defined restart boundary.
// NDF-END: PTO-SWI-ADR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SWI() => ScalarOperation
begin
    return ScalarOperation_SWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SWI()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
