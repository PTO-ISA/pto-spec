// PTO-INSTRUCTION: {"assembly":["FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm"],"block":[],"catalog_indices":[62],"catalog_records":[{"asm":"FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm","constraints":[{"field":"SrcBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SrcEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000041","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcBegin","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcEnd","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm","pieces":[{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}],"signedness":"unsigned","width":15}],"form_id":"fentry_32_a47584ec13b6","length_bits":32,"mnemonic":"FENTRY","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteFrameEntry","semantic_summary":"Creates a restartable stack frame by snapshotting and storing one inclusive callee-save register-ring range.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm"],"defaults":["The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.","uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.","The source range is snapshotted before sp changes, so a range containing sp stores the caller sp."],"encoding_class":"standalone-encoded","examples":["FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm"],"exceptions":["Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.","Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state."],"field_contracts":{},"field_zero_meanings":{"SrcBegin":"Encoded zero is outside the callee-save ring and is reserved.","SrcEnd":"Encoded zero is outside the callee-save ring and is reserved.","uimm":"Encoded zero is a real zero-byte frame size and is illegal for every nonempty range."},"legality":["SrcBegin and SrcEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.","If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight."],"memory_effects":["Store one aligned eight-byte snapshot per selected register into consecutive descending slots below the caller sp.","Every store records one relaxed store event and follows the ordinary PTO precise data-access fault contract."],"operands":[{"field":"SrcBegin","role":"first register in the inclusive R2..R23 ring range"},{"field":"SrcEnd","role":"last register in the inclusive R2..R23 ring range"},{"field":"uimm","role":"frame byte count, encoded in multiples of eight"}],"ordering":["Snapshot the complete source range, subtract uimm from sp, then store snapshots in range order to caller_sp-8, caller_sp-16, and subsequent descending slots.","Each store and progress advance commit atomically; recovery never rereads source registers or repeats an earlier store."],"standalone_opcode":true,"state_effects":["The accepted start records instruction PC, endpoints, count, frame size, caller sp, complete source snapshot, and zero progress.","After the final store, increment frame depth, publish the last-frame tuple, clear active progress, and retire once."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-FENTRY","mnemonic":"FENTRY","summary":"Creates a restartable stack frame by snapshotting and storing one inclusive callee-save register-ring range.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;

func ExecuteFENTRY(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    EnterFrame(begin_reg, end_reg, frame_size);
end;

pure func InstructionContractUsesHalfOpenRegisterRange_FENTRY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FENTRY()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
