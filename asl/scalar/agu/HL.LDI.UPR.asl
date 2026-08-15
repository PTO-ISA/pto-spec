// PTO-INSTRUCTION: {"assembly":["hl.ldi.upr [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[173],"catalog_records":[{"agu":{"action":"Load","address_kind":"Immediate","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":8,"update_mode":"PreIndex"},"asm":"hl.ldi.upr [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00003029002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_ldi_upr_48_7a8e2794526f","length_bits":48,"mnemonic":"HL.LDI.UPR","semantic_family":"AGU","semantic_group":"LDA/PRE_INDEX","semantic_handler":"ExecuteScalarLoad","semantic_summary":"HL.LDI.UPR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.ldi.upr [SrcL, simm], ->Dst0, Dst1"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["hl.ldi.upr [SrcL, simm], ->Dst0, Dst1"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards this result without suppressing the instruction's other effects.","RegDst1":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","simm17":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.","Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst0","role":"Reg5 first loaded-value destination or discard"},{"field":"RegDst1","role":"Reg5 updated-base destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"simm17","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.","Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.","After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LDI-UPR","mnemonic":"HL.LDI.UPR","summary":"HL.LDI.UPR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LDI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_UPR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LDI_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LDI_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LDI_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LDI_UPR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_LDI_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LDI_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LDI_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LDI_UPR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
