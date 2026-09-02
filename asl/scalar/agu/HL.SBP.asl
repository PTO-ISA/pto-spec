// PTO-INSTRUCTION: {"assembly":["hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]"],"block":[],"catalog_indices":[243],"catalog_records":[{"agu":{"action":"StorePair","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]","constraints":[{"field":"SrcRType","operator":"one-of","values":[0,1,2]}],"encoding":[{"index":0,"mask":"0x00007ffff83f","match":"0x00000049001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sbp_48_12e03c011f0a","length_bits":48,"mnemonic":"HL.SBP","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","semantic_summary":"HL.SBP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. The register offset uses a fixed scale factor of 1; no shamt field is encoded."],"encoding_class":"standalone-encoded","examples":["hl.sbp SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw}>]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"SrcD":"Encoded zero reads the architectural zero GPR.","SrcD1":"Encoded zero reads the architectural zero GPR.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero leaves the complete PTO_XLEN register-offset value unchanged."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","All four SrcRType values are assigned; apply the selected modifier with the fixed scale factor of 1.","Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit."],"memory_effects":["Preflight both adjacent 1-byte addresses before either store; on success record two relaxed store events in address order.","Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight."],"operands":[{"field":"SrcD","role":"Reg5 first store-data source"},{"field":"SrcD1","role":"Reg5 second store-data source"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.","The pair addresses are address and address plus 1; the instruction performs no base writeback.","Snapshot every store-data source before any memory effect or destination publication.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-SBP","mnemonic":"HL.SBP","summary":"HL.SBP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SBP() => ScalarOperation
begin
    return ScalarOperation_HL_SBP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SBP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SBP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SBP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SBP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SBP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBP()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
