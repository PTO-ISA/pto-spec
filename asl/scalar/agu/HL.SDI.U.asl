// PTO-INSTRUCTION: {"assembly":["hl.sdi.u SrcD, [SrcR, simm]"],"block":[],"catalog_indices":[252],"catalog_records":[{"agu":{"action":"Store","address_kind":"Immediate","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":8,"update_mode":"None"},"asm":"hl.sdi.u SrcD, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00007059000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm22","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}],"signedness":"signed","width":22}],"form_id":"hl_sdi_u_48_d9597eeba6b4","length_bits":48,"mnemonic":"HL.SDI.U","semantic_family":"AGU","semantic_group":"STA/LONG","semantic_handler":"ExecuteScalarStore","semantic_summary":"HL.SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.sdi.u SrcD, [SrcR, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["hl.sdi.u SrcD, [SrcR, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","simm22":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 1.","Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.","A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid."],"operands":[{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcR","role":"Reg5 address-base source"},{"field":"simm22","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm22, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SDI-U","mnemonic":"HL.SDI.U","summary":"HL.SDI.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SDI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_U()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
