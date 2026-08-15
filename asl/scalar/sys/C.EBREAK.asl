// PTO-INSTRUCTION: {"assembly":["c.break imm"],"block":[],"catalog_indices":[36],"catalog_records":[{"asm":"c.break imm","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0xc02c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"imm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_ebreak_16_7f9c245fa13c","length_bits":16,"mnemonic":"C.EBREAK","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SoftwareBreakpoint","semantic_summary":"C.EBREAK raises software-breakpoint trap 50 with its 5-bit immediate as cause.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["C.EBREAK executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["c.break imm"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["c.break imm"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"imm5":"Encoded zero supplies numeric zero for the 5-bit immediate value."},"legality":["Every 5-bit immediate value is assigned; encoded zero is a real zero cause."],"memory_effects":["none"],"operands":[{"field":"imm5","role":"5-bit immediate value"}],"ordering":["After placement and decode, atomically save the pre-instruction context, trap number, zero-extended immediate cause, and faulting-PC argument before vector transfer."],"standalone_opcode":true,"state_effects":["Raise Fault_SoftwareBreakpoint and publish trap number 50.","Zero-extend the encoded immediate into the 24-bit trap-cause field; no parallel breakpoint-tag state exists."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-C-EBREAK","mnemonic":"C.EBREAK","summary":"C.EBREAK raises software-breakpoint trap 50 with its 5-bit immediate as cause.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_C_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_C_EBREAK()
    => integer {4,5}
begin
    return 5;
end;

pure func InstructionContractBreakpointPublishesTrapCause_C_EBREAK()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
