// PTO-INSTRUCTION: {"assembly":["c.setret uimm, ->ra"],"block":[],"catalog_indices":[46],"catalog_records":[{"asm":"c.setret uimm, ->ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x5016","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"c_setret_16_335651ef6c27","length_bits":16,"mnemonic":"C.SETRET","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"SetReturnAddress","semantic_summary":"Materialize an unsigned halfword-scaled TPC-relative return address in ra and captured return state.","status":"accepted"}],"classification":["alu"],"contract":{"block_composition":["Standalone scalar return-address materialization. Fused BSTART.CALL and BSTART.ICALL define call formation separately."],"canonical_assembly":["c.setret uimm, ->ra"],"defaults":["C.SETRET has no omitted field. Encoded uimm5 zero is the real zero displacement and materializes the address of C.SETRET itself."],"encoding_class":"standalone-encoded","examples":["c.setret 0, ->ra","c.setret 31, ->ra"],"exceptions":["All uimm5 values are legal. C.SETRET performs no target dereference and raises no alignment, memory, arithmetic, or block-control exception."],"field_contracts":{},"field_zero_meanings":{"uimm5":"Encoded zero supplies numeric zero for the 5-bit unsigned immediate."},"legality":["Every uimm5 value 0..31 is assigned. The fixed destination is architectural ra (GPR10).","C.SETRET is legal as a standalone scalar operation and does not by itself form a call."],"memory_effects":["none"],"operands":[{"field":"uimm5","role":"unsigned five-bit halfword displacement from the pre-increment TPC"}],"ordering":["Snapshot the pre-increment TPC, compute the target, publish ra and captured return state together, then perform the ordinary two-byte sequential TPC advance."],"standalone_opcode":true,"state_effects":["Compute target = pre-increment TPC + (ZeroExtend(uimm5) << 1) with XLEN wrapping.","Atomically write the same target to GPR10 ra and the captured return-address state; successful dispatch then advances TPC by two bytes.","A later ordinary write to ra does not retroactively change the captured return-address state."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-C-SETRET","mnemonic":"C.SETRET","summary":"Materialize an unsigned halfword-scaled TPC-relative return address in ra and captured return state.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETRET() => ScalarOperation
begin
    return ScalarOperation_C_SETRET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractTarget_C_SETRET(
    tpc: Word,
    uimm5: bits(5))
    => Word
begin
    let halfword_offset = ZeroExtend{PTO_XLEN}(uimm5);
    return tpc + LSL(halfword_offset, 1);
end;
// DOC-END: operation
