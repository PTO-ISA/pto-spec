// PTO-INSTRUCTION: {"assembly":["hl.qpop SrcL, ->RegDst0, RegDst1","hl.qpop.e SrcL, ->RegDst0, RegDst1","hl.qpop.r SrcL, ->RegDst0, RegDst1","hl.qpop.er SrcL, ->RegDst0, RegDst1"],"block":[],"catalog_indices":[67],"catalog_records":[{"asm":"hl.qpop[.{e,r,er}] SrcL, ->RegDst0, RegDst1","constraints":[],"encoding":[{"index":0,"mask":"0xf9f0707f07ff","match":"0x0000207d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"e","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"r","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_qpop_48_a2c57f5bc27b","length_bits":48,"mnemonic":"HL.QPOP","semantic_family":"CMD","semantic_group":"General","semantic_handler":"ExecuteQueuePop","semantic_summary":"Atomically pops one 64-bit head entry from a General Queue Management queue.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.qpop SrcL, ->RegDst0, RegDst1","hl.qpop.e SrcL, ->RegDst0, RegDst1","hl.qpop.r SrcL, ->RegDst0, RegDst1","hl.qpop.er SrcL, ->RegDst0, RegDst1"],"defaults":["The bare form has acquire semantics and publishes no event.","e=0 suppresses notification and r=0 selects acquire ordering.","Bits [40:36] are fixed reserved-zero bits and are never an operand."],"encoding_class":"standalone-encoded","examples":["hl.qpop a0, ->a1, a2","hl.qpop.e t#1, ->t#2, u#1","hl.qpop.r sp, ->zero, a0"],"exceptions":["Nonzero reserved bits [40:36] and selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.","Empty, missing, and corrupt queues report status in RegDst1 and do not trap."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero names R0; reads produce zero and writes are discarded.","RegDst0":"Encoded zero names R0; reads produce zero and writes are discarded.","RegDst1":"Encoded zero names R0; reads produce zero and writes are discarded.","e":"Zero suppresses event notification.","r":"Zero selects acquire ordering."},"legality":["Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.","All four e/r flag combinations are assigned.","Any nonzero value in bits [40:36] is reserved and raises Fault_IllegalInstruction before source reads or effects."],"memory_effects":["No direct memory access. A non-relaxed successful pop acquires memory operations released by the observed entry's non-relaxed push."],"operands":[{"field":"SrcL","role":"Reg5 source of the queue address"},{"field":"RegDst0","role":"Reg5 destination for popped data"},{"field":"RegDst1","role":"Reg5 destination for the operation result"},{"field":"e","role":"success-event selector"},{"field":"r","role":"relaxed-ordering selector"}],"ordering":["Queue validation and data selection precede the atomic head removal. A successful removal precedes optional event notification and the ordered RegDst0 then RegDst1 writes.","r=0 establishes the acquire edge; r=1 is relaxed and records no acquire edge. Destination aliases follow ordered multi-destination write rules."],"standalone_opcode":true,"state_effects":["A successful pop removes the head entry even while the queue is suspended, writes its value to RegDst0, and reports status zero.","RegDst1[12:0] holds the post-attempt remaining entry count and [63:62] holds status; unused bits are zero. Status 1 is empty, 2 is missing or corrupt, and 3 is reserved.","Only a successful pop with e=1 broadcasts an event. The queue update and both destination writes are one instruction effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-HL-QPOP","mnemonic":"HL.QPOP","summary":"Atomically pops one 64-bit head entry from a General Queue Management queue.","surface":"block"}
// NDF-BEGIN: PTO-HL-QPOP-GQM-001
// ndf: kind=contract level=L1 layer=block status=accepted
// HL.QPOP MUST atomically remove one head entry, optionally notify after
// success, publish data before status, and provide acquire ordering unless r=1.
// Empty, missing, or corrupt queues MUST report status without a queue update.
// NDF-END: PTO-HL-QPOP-GQM-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_QPOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpop_48_a2c57f5bc27b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_QPOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePop;
end;

func ExecuteHLQPOP(destination0: Reg5Selector,
                   destination1: Reg5Selector,
                   address: Word,
                   flags: bits(4))
begin
    ExecuteQueueManagerPop(
        destination0,
        destination1,
        address,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPOP()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
