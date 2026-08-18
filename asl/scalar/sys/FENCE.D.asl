// PTO-INSTRUCTION: {"assembly":["fence.d pred_imm, succ_imm"],"block":[],"catalog_indices":[96],"catalog_records":[{"asm":"fence.d pred_imm, succ_imm","constraints":[],"encoding":[{"index":0,"mask":"0xf00fffff","match":"0x0000202b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"PRED_IMM","pieces":[{"instruction_lsb":24,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"SUCC_IMM","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"fence_d_32_f4783f17d84d","length_bits":32,"mnemonic":"FENCE.D","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"FenceData","semantic_summary":"FENCE.D records predecessor/successor ordering masks and invalidates the local reservation.","status":"accepted"}],"classification":["sys"],"contract":{"block_composition":["FENCE.D executes as one scalar operation in the body of an active SYS block."],"canonical_assembly":["fence.d pred_imm, succ_imm"],"defaults":["Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission."],"encoding_class":"standalone-encoded","examples":["fence.d pred_imm, succ_imm"],"exceptions":["Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.","A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects."],"field_contracts":{},"field_zero_meanings":{"PRED_IMM":"Encoded zero selects value zero of the fence predecessor access-class mask.","SUCC_IMM":"Encoded zero selects value zero of the fence successor access-class mask."},"legality":["All sixteen values of each four-bit predecessor and successor mask are assigned."],"memory_effects":["none"],"operands":[{"field":"PRED_IMM","role":"fence predecessor access-class mask"},{"field":"SUCC_IMM","role":"fence successor access-class mask"}],"ordering":["Record the exact predecessor and successor masks as one data-fence event.","If either mask carries the instruction-visibility bit, advance the instruction-cache epoch."],"standalone_opcode":true,"state_effects":["Invalidate the local reservation, record both masks, emit the fence event, and advance TPC."]},"depends_on":["PTO-SCALAR-MODEL-SYS-SEMANTICS"],"id":"PTO-SCALAR-FENCE-D","mnemonic":"FENCE.D","summary":"FENCE.D records predecessor/successor ordering masks and invalidates the local reservation.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-FENCE-D-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// FENCE.D MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-FENCE-D-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FENCE_D()
    => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENCE_D()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;

pure func InstructionContractRequiresSystemBlock_FENCE_D()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractFenceMaskWidth_FENCE_D()
    => integer {4}
begin
    return 4;
end;

pure func InstructionContractFenceInvalidatesReservation_FENCE_D()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
