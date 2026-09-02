// PTO-INSTRUCTION: {"assembly":["hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}"],"block":[],"catalog_indices":[229],"catalog_records":[{"agu":{"action":"Prefetch","address_kind":"Register","offset_scale":0,"prefetch_returns_address":true,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}","constraints":[{"field":"model","operator":"one-of","values":[0,1,2]}],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x00007009001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"model","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_prf_a_48_267dc57d14f4","length_bits":48,"mnemonic":"HL.PRF.A","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ScalarPrefetch","semantic_summary":"HL.PRF.A snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.","model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint."],"encoding_class":"standalone-encoded","examples":["hl.prf.a{.l1,.l2,.l3} [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->{t, u, Rd}"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards this result without suppressing the instruction's other effects.","SrcL":"Encoded zero reads the architectural zero GPR.","SrcR":"Encoded zero reads the architectural zero GPR.","SrcRType":"Encoded zero leaves the complete PTO_XLEN register-offset value unchanged.","model":"Encoded zero selects the non-binding L1 cache hint.","shamt":"Encoded zero performs no shift."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.","SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.","model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect."],"memory_effects":["The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee."],"operands":[{"field":"RegDst","role":"Reg5 effective-address destination or discard"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"SrcR","role":"Reg5 register-offset source"},{"field":"SrcRType","role":"register-offset transformation selector"},{"field":"model","role":"cache-level hint selector"},{"field":"shamt","role":"post-transformation logical-left-shift amount"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","For a legal model, form the hint, publish the optional address result, and then advance TPC by 6 bytes."],"standalone_opcode":true,"state_effects":["Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.","Publish the modulo-2^PTO_XLEN effective address through the Reg5 destination after source snapshot.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-PRF-A","mnemonic":"HL.PRF.A","summary":"HL.PRF.A snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint and publishes the effective address.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-HL-PRF-A-CACHE-MODEL-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// HL.PRF.A MUST assign model 0 to L1, 1 to L2, and 2 to L3.
// Model values 3 through 31 MUST reject before scalar source reads or effects.
// Legal hints MUST form the encoded address without translation, memory event,
// ordering edge, data-access fault, or architecturally guaranteed placement.
// The effective address MUST be published through RegDst after source snapshot.
// NDF-END: PTO-HL-PRF-A-CACHE-MODEL-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_PRF_A() => ScalarOperation
begin
    return ScalarOperation_HL_PRF_A;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_PRF_A()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRF_A()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRF_A()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_PRF_A()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRF_A()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRF_A()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRF_A()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRF_A()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
