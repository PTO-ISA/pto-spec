// PTO-INSTRUCTION: {"assembly":["prfi.u [SrcL, simm]"],"block":[],"catalog_indices":[379],"catalog_records":[{"agu":{"action":"Prefetch","address_kind":"Immediate","offset_scale":0,"prefetch_returns_address":false,"signed_load":false,"size_bytes":1,"update_mode":"None"},"asm":"prfi.u [SrcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007029","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"prfi_u_32_167b42882547","length_bits":32,"mnemonic":"PRFI.U","semantic_family":"AGU","semantic_group":"LDA/UNSCALED","semantic_handler":"ScalarPrefetch","semantic_summary":"PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","status":"accepted"}],"classification":["agu"],"contract":{"block_composition":["none"],"canonical_assembly":["prfi.u [SrcL, simm]"],"defaults":["Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["prfi.u [SrcL, simm]"],"exceptions":["A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.","A legal prefetch model cannot raise a data-access fault. A reserved model rejects before source reads and before optional address publication."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero is the canonical ignored alias value and names no destination.","SrcL":"Encoded zero reads the architectural zero GPR.","simm12":"Encoded zero supplies a zero displacement; it does not denote omission."},"legality":["Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.","Every encoded RegDst value is an assigned non-writing alias. Canonical assembly uses zero and does not expose a destination.","simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1."],"memory_effects":["The 1-byte-granularity hint performs no architectural translation, permission or alignment check, memory access, memory event, reservation update, ordering edge, or cache-placement guarantee."],"operands":[{"field":"RegDst","role":"ignored encoded alias field"},{"field":"SrcL","role":"Reg5 address-base source"},{"field":"simm12","role":"signed address displacement"}],"ordering":["Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.","For a legal model, form the hint, publish the optional address result, and then advance TPC by 4 bytes."],"standalone_opcode":true,"state_effects":["Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.","Discard the formed address after issuing the non-binding hint; no encoded field publishes a result.","Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-PRFI-U","mnemonic":"PRFI.U","summary":"PRFI.U snapshots its scalar sources, forms its encoded address, and issues a non-binding 1-byte-granularity prefetch hint with no destination effect.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_PRFI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_PRFI_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;

pure func InstructionContractAGUAction_PRFI_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Prefetch;
end;

pure func InstructionContractAGUAddressKind_PRFI_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_PRFI_U()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_PRFI_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_PRFI_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_PRFI_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_PRFI_U()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
