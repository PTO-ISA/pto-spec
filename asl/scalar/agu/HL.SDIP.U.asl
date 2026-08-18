// PTO-INSTRUCTION: {"assembly":["hl.sdip.u SrcD, SrcD1, [SrcR, simm]"],"block":[],"catalog_indices":[256],"catalog_records":[{"agu":{"action":"StorePair","address_kind":"Immediate","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":8,"update_mode":"None"},"asm":"hl.sdip.u SrcD, SrcD1, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00007059001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_sdip_u_48_3260b03bb762","length_bits":48,"mnemonic":"HL.SDIP.U","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","semantic_summary":"HL.SDIP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 8-byte values.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.sdip.u SrcD, SrcD1, [SrcR, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["hl.sdip.u SrcD, SrcD1, [SrcR, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcD1":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","simm17":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.","Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit."],"memory_effects":["Preflight both adjacent 8-byte addresses before either store; on success record two relaxed store events in address order.","Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight."],"operands":[{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcD1","role":"Reg5 second store-data source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"simm17","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.","The pair addresses are address and address plus 8; the instruction performs no base writeback.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SDIP-U","mnemonic":"HL.SDIP.U","summary":"HL.SDIP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 8-byte values.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SDIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SDIP_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SDIP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SDIP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SDIP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDIP_U()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDIP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDIP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDIP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDIP_U()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
