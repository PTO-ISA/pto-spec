// PTO-INSTRUCTION: {"assembly":["MCOPY [RegSrc0, RegSrc1, RegSrc2]"],"block":[],"catalog_indices":[69],"catalog_records":[{"asm":"MCOPY [RegSrc0, RegSrc1, RegSrc2]","constraints":[{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00000031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mcopy_32_4fc4a803e995","length_bits":32,"mnemonic":"MCOPY","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteMemoryCopy","semantic_summary":"Copies a non-overlapping byte range in restartable forward memory steps.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["MCOPY is one standalone template block. It retires only after the complete byte range has copied or after a legal zero-length no-op."],"canonical_assembly":["MCOPY [RegSrc0, RegSrc1, RegSrc2]"],"defaults":["No operand is omitted. RegSrc0, RegSrc1, and RegSrc2 are absolute GPR selectors 0..23; selector zero reads architectural zero.","RegSrc2 supplies the complete unsigned XLEN byte count. Zero length is legal and performs no memory access."],"encoding_class":"standalone-encoded","examples":["MCOPY [a0, a1, a2]"],"exceptions":["Selector codes 24..31, a wrapping source or destination interval, or overlapping nonempty intervals raise Fault_IllegalInstruction before register-dependent memory, event, reservation, progress, last-command, or TPC effects.","A source or destination access fault is precise to the current memory step. Earlier completed steps remain visible; the rejected step has no read, write, event, reservation, or progress effect."],"field_contracts":{},"field_zero_meanings":{"RegSrc0":"Encoded zero reads destination byte address zero.","RegSrc1":"Encoded zero reads source byte address zero.","RegSrc2":"Encoded zero reads length zero and selects the legal memory-free no-op."},"legality":["Each RegSrc field accepts exactly absolute GPR selectors 0..23. Relative T/U selector codes 24..31 are reserved for MCOPY.","For nonzero length, both half-open intervals must be non-wrapping and disjoint."],"memory_effects":["Copy forward from source to destination in 8-, 4-, 2-, or 1-byte steps. Each step probes source and destination before reading, then records the source load and destination store in program order.","The step write invalidates an overlapping local reservation. A successful zero-length command performs no access and does not change reservation state."],"operands":[{"field":"RegSrc0","role":"absolute GPR containing destination byte address"},{"field":"RegSrc1","role":"absolute GPR containing source byte address"},{"field":"RegSrc2","role":"absolute GPR containing complete unsigned XLEN byte count"}],"ordering":["Each source read precedes its corresponding destination write. The write and progress advance commit together at one restart boundary.","On recovery the template resumes from its saved operand snapshot and first uncommitted byte without rereading GPRs or repeating earlier memory events."],"standalone_opcode":true,"state_effects":["At accepted start, snapshot destination, source, length, instruction PC, and zero progress into trap-preserved MemoryCopyTemplateState.","After the final step, clear active progress, record the original destination and full length as the last memory command, and retire exactly once."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-MCOPY","mnemonic":"MCOPY","summary":"Copies a non-overlapping byte range in restartable forward memory steps.","surface":"block"}
// NDF-BEGIN: PTO-MCOPY-RESTART-001
// ndf: kind=contract level=L1 layer=block status=accepted
// MCOPY MUST snapshot absolute GPR destination, source, and complete XLEN
// length, reject wrapping or overlapping nonempty ranges, and copy forward.
// Each memory step MUST be an exact restart boundary and MUST NOT be repeated.
// NDF-END: PTO-MCOPY-RESTART-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;

pure func InstructionContractMemoryStepRestartable_MCOPY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractForbidsOverlap_MCOPY()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
