// PTO-INSTRUCTION: {"assembly":["fence.i"],"block":[],"catalog_indices":[105],"catalog_records":[{"asm":"fence.i","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x1000202b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"fence_i_32_a321a2a186b1","length_bits":32,"mnemonic":"FENCE.I","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"FenceInstruction","semantic_summary":"FENCE.I establishes instruction visibility, invalidates the reservation, and advances the instruction-cache epoch.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["FENCE.I executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["fence.i"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.","The instruction has no operand or mask field."],"encoding_class":"standalone-encoded","examples":["fence.i"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["Every fixed bit and explicit field constraint is checked before operation semantics."],"memory_effects":["none"],"operands":[],"ordering":["Check block placement and encoded legality before architectural effects.","Invalidate the local reservation and advance the instruction-cache epoch exactly once; FENCE.I emits no data-memory event."],"standalone_opcode":true,"state_effects":["Invalidate the local reservation, advance the instruction-cache epoch exactly once, and advance TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-FENCE-I","mnemonic":"FENCE.I","summary":"FENCE.I establishes instruction visibility, invalidates the reservation, and advances the instruction-cache epoch.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FENCE_I()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENCE_I()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_I()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAdvancesInstructionEpoch_FENCE_I()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
