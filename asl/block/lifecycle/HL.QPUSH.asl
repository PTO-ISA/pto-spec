// PTO-INSTRUCTION: {"assembly":["hl.qpush SrcL, SrcR, ->RegDst","hl.qpush.h SrcL, SrcR, ->RegDst","hl.qpush.e SrcL, SrcR, ->RegDst","hl.qpush.r SrcL, SrcR, ->RegDst","hl.qpush.he SrcL, SrcR, ->RegDst","hl.qpush.hr SrcL, SrcR, ->RegDst","hl.qpush.er SrcL, SrcR, ->RegDst","hl.qpush.her SrcL, SrcR, ->RegDst"],"block":[],"catalog_indices":[68],"catalog_records":[{"asm":"hl.qpush[.{h,e,r,he,hr,er,her}] SrcL, SrcR, ->RegDst","constraints":[],"encoding":[{"index":0,"mask":"0xf000707fffff","match":"0x0000107d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"e","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"h","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"r","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_qpush_48_3eab8e05d61a","length_bits":48,"mnemonic":"HL.QPUSH","semantic_family":"CMD","semantic_group":"General","semantic_handler":"ExecuteQueuePush","semantic_summary":"Atomically pushes one 64-bit entry at the tail or head of a General Queue Management queue.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.qpush SrcL, SrcR, ->RegDst","hl.qpush.h SrcL, SrcR, ->RegDst","hl.qpush.e SrcL, SrcR, ->RegDst","hl.qpush.r SrcL, SrcR, ->RegDst","hl.qpush.he SrcL, SrcR, ->RegDst","hl.qpush.hr SrcL, SrcR, ->RegDst","hl.qpush.er SrcL, SrcR, ->RegDst","hl.qpush.her SrcL, SrcR, ->RegDst"],"defaults":["The bare form appends at the tail, publishes no event, and has release semantics.","h=0 selects tail insertion, e=0 suppresses notification, and r=0 selects release ordering."],"encoding_class":"standalone-encoded","examples":["hl.qpush a0, a1, ->a2","hl.qpush.he t#1, u#1, ->t#2","hl.qpush.r sp, zero, ->u#1"],"exceptions":["Selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.","Full, suspended, missing, and corrupt queues report status in RegDst and do not trap."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names R0; reads produce zero and writes are discarded.","SrcR":"Encoded zero names R0; reads produce zero and writes are discarded.","RegDst":"Encoded zero names R0; reads produce zero and writes are discarded.","h":"Zero appends at the queue tail.","e":"Zero suppresses event notification.","r":"Zero selects release ordering."},"legality":["Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.","All eight h/e/r flag combinations are assigned; the event suffix is e and b is not an alias."],"memory_effects":["No direct memory access. A non-relaxed successful push releases memory operations ordered before it to an acquiring pop that observes the entry."],"operands":[{"field":"SrcL","role":"Reg5 source of the queue address"},{"field":"SrcR","role":"Reg5 source of the 64-bit entry"},{"field":"RegDst","role":"Reg5 destination for the operation result"},{"field":"h","role":"head-insertion selector"},{"field":"e","role":"success-event selector"},{"field":"r","role":"relaxed-ordering selector"}],"ordering":["Queue validation precedes insertion. A successful insertion precedes optional event notification and result publication.","r=0 establishes the release edge; r=1 is relaxed and records no release edge."],"standalone_opcode":true,"state_effects":["h=0 appends one entry at the tail; h=1 inserts one entry at the head. The queue update, optional event, and destination result are atomic.","Result bits [9:0] hold post-push remaining capacity and [63:62] hold status; unused bits are zero. Status 0 is success, 1 is full or suspended, 2 is missing or corrupt, and 3 is reserved.","Only a successful push with e=1 broadcasts an event."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-HL-QPUSH","mnemonic":"HL.QPUSH","summary":"Atomically pushes one 64-bit entry at the tail or head of a General Queue Management queue.","surface":"block"}
// NDF-BEGIN: PTO-HL-QPUSH-GQM-001
// ndf: kind=contract level=L1 layer=block status=accepted
// HL.QPUSH MUST atomically insert one entry at the tail or head, optionally
// notify after success, and provide release ordering unless r=1.
// Full, suspended, missing, or corrupt queues MUST report status without insertion.
// NDF-END: PTO-HL-QPUSH-GQM-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_QPUSH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpush_48_3eab8e05d61a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_QPUSH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePush;
end;

func ExecuteHLQPUSH(destination: Reg5Selector,
                    address: Word,
                    entry: Word,
                    flags: bits(4))
begin
    ExecuteQueueManagerPush(
        destination,
        address,
        entry,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
