// PTO-INSTRUCTION: {"assembly":["hl.lhu.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"block":[],"catalog_indices":[191],"catalog_records":[{"agu":{"action":"Load","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":2,"update_mode":"PreIndex"},"asm":"hl.lhu.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x00005009002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_lhu_pr_48_f874b126e29c","length_bits":48,"mnemonic":"HL.LHU.PR","semantic_family":"AGU","semantic_group":"LDA/PRE_INDEX","semantic_handler":"ExecuteScalarLoad","semantic_summary":"HL.LHU.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.lhu.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 negates the full PTO_XLEN value. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["hl.lhu.pr [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.","A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.","Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress."],"field_contracts":{},"field_zero_meanings":{"RegDst0":"Encoded zero discards this result without suppressing the instruction's other effects.","RegDst1":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero leaves the complete PTO_XLEN register-offset value unchanged.","shamt":"Encoded zero performs no shift."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.","Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit."],"memory_effects":["After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.","The load preserves memory and reservation state."],"operands":[{"field":"RegDst0","role":"Reg5 first loaded-value destination or discard"},{"field":"RegDst1","role":"Reg5 updated-base destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.","Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.","After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-LHU-PR","mnemonic":"HL.LHU.PR","summary":"HL.LHU.PR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LHU_PR() => ScalarOperation
begin
    return ScalarOperation_HL_LHU_PR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LHU_PR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LHU_PR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LHU_PR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LHU_PR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHU_PR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LHU_PR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_LHU_PR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHU_PR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
