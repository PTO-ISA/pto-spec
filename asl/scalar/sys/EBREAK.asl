// PTO-INSTRUCTION: {"assembly":["ebreak imm"],"block":[],"catalog_indices":[86],"catalog_records":[{"asm":"ebreak imm","constraints":[],"encoding":[{"index":0,"mask":"0xf0ffffff","match":"0x0010102b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"imm4","pieces":[{"instruction_lsb":24,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"ebreak_32_4f122d1e6be3","length_bits":32,"mnemonic":"EBREAK","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SoftwareBreakpoint","semantic_summary":"EBREAK raises software-breakpoint trap 50 with its 4-bit immediate as cause.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["EBREAK executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["ebreak imm"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["ebreak imm"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"imm4":"Encoded zero supplies numeric zero for the 4-bit immediate value."},"legality":["Every 4-bit immediate value is assigned; encoded zero is a real zero cause."],"memory_effects":["none"],"operands":[{"field":"imm4","role":"4-bit immediate value"}],"ordering":["After placement and decode, atomically save the pre-instruction context, trap number, zero-extended immediate cause, and faulting-PC argument before vector transfer."],"standalone_opcode":true,"state_effects":["Raise Fault_SoftwareBreakpoint and publish trap number 50.","Zero-extend the encoded immediate into the 24-bit trap-cause field; no parallel breakpoint-tag state exists."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-EBREAK","mnemonic":"EBREAK","summary":"EBREAK raises software-breakpoint trap 50 with its 4-bit immediate as cause.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-EBREAK-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// EBREAK MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-EBREAK-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_EBREAK()
    => integer {4,5}
begin
    return 4;
end;

pure func InstructionContractBreakpointPublishesTrapCause_EBREAK()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
