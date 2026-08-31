// PTO-INSTRUCTION: {"assembly":["prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]"],"block":[],"catalog_indices":[370],"catalog_records":[{"agu":{"action":"Prefetch","address_kind":"Register","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007009","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"prf_32_30e6dfe4e3ce","length_bits":32,"mnemonic":"PRF","semantic_family":"AGU","semantic_group":"LDA/BASE_REG","semantic_handler":"ScalarPrefetch","semantic_summary":"PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift."],"encoding_class":"standalone-encoded","examples":["prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero is the canonical ignored alias value and names no destination.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier.","shamt":"Encoded zero performs no shift."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.","All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift."],"memory_effects":["The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee."],"operands":[{"field":"RegDst","role":"ignored encoded alias field"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.","Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-PRF","mnemonic":"PRF","summary":"PRF snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-PRF-NONFAULTING-HINT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// PRF MUST form its modified and shifted register address as a non-faulting
// hint. Every encoded RegDst value is a non-writing alias, and legal execution
// MUST perform no translation, memory event, ordering edge, or destination effect.
// NDF-END: PTO-PRF-NONFAULTING-HINT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_PRF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRF()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRF()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_PRF()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRF()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRF()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRF()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRF()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
