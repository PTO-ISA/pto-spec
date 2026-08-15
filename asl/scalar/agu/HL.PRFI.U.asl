// PTO-INSTRUCTION: {"assembly":["hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]"],"block":[],"catalog_indices":[238],"catalog_records":[{"agu":{"action":"Prefetch","address_kind":"Immediate","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]","constraints":[{"field":"model","operator":"one-of","values":[0,1,2]}],"encoding":[{"index":0,"mask":"0x00007fff003f","match":"0x00007029000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"model","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_prfi_u_48_be73891e376e","length_bits":48,"mnemonic":"HL.PRFI.U","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ScalarPrefetch","semantic_summary":"HL.PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.","model=0 selects L1, model=1 selects L2, and model=2 selects L3; the cache target is a non-binding performance hint."],"encoding_class":"standalone-encoded","examples":["hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero GPR.","model":"Encoded zero selects the non-binding L1 cache hint.","simm17":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.","model codes 0, 1, and 2 are assigned; codes 3..31 are reserved and raise Fault_IllegalInstruction before any scalar source read or architectural effect."],"memory_effects":["The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee."],"operands":[{"field":"SrcL","role":"Reg5 address-base source"},{"field":"model","role":"cache-level hint selector"},{"field":"simm17","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","For a legal model, form the hint, publish the optional address result, and then advance TPC by 6 bytes."],"standalone_opcode":true,"state_effects":["Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.","Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.","Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-PRFI-U","mnemonic":"HL.PRFI.U","summary":"HL.PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_PRFI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_HL_PRFI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_HL_PRFI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_PRFI_U()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_PRFI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_PRFI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_PRFI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_PRFI_U()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
