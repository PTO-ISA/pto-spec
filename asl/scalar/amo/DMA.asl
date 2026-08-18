// PTO-INSTRUCTION: {"assembly":["dma [SrcL], SrcR"],"block":[],"catalog_indices":[81],"catalog_records":[{"asm":"dma [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xfe007fff","match":"0x0000700b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dma_32_a168aeca5fa5","length_bits":32,"mnemonic":"DMA","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"ExecuteScalarDMACopy64","semantic_summary":"DMA performs an exact 64-byte copy, validates both ranges before effects, snapshots the source so overlap has memmove semantics, and guarantees that any fault leaves memory unchanged for precise full reissue.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["dma [SrcL], SrcR"],"defaults":["SrcL and SrcR are required Reg5 source fields. Encoded source zero reads the architectural zero register as byte address zero; no field value denotes omission.","DMA has no ordering, route, destination, or size modifier. The copy size is always 64 bytes, its alignment requirement is one byte, and every successful memory event is relaxed."],"encoding_class":"standalone-encoded","examples":["dma [a0], a1","dma [t#1], u#1","dma [zero], sp"],"exceptions":["Bits 31:25 are fixed zero by the instruction match. Any other fixed-bit pattern is not DMA and raises Fault_IllegalInstruction before effects when it has no other legal owner.","The source range is probed before the destination range. The first failing alignment, translation, permission, or bounded-memory check reports the original architectural address.","A source or destination fault occurs before any source byte read, memory event, destination write, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores it for full reissue."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero register as source byte address zero.","SrcR":"Encoded zero reads the architectural zero register as destination byte address zero."},"legality":["All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","Both complete 64-byte ranges must pass access preflight. The source range is probed before the destination range and the first failing probe wins.","Every byte address is naturally aligned because DMA requires one-byte alignment. Exact overlap, forward overlap, backward overlap, and disjoint ranges are all legal."],"memory_effects":["Probe the complete 64-byte source range for read access, then the complete 64-byte destination range for write access, before reading or writing architectural memory.","All 64 source bytes are snapshotted before the first destination write, giving exact, forward, and backward overlap memmove semantics.","A successful captured execution emits eight ordered 8-byte relaxed load events followed by eight ordered 8-byte relaxed store events. Each store event value is derived from the corresponding chunk of the single source snapshot.","The destination store invalidates an overlapping local reservation and preserves a nonoverlapping reservation. Either fault preserves the prior reservation."],"operands":[{"field":"SrcL","role":"Reg5 source byte-address source"},{"field":"SrcR","role":"Reg5 destination byte-address source"}],"ordering":["The eight load events precede all eight store events in instruction program order. Every event uses relaxed ordering.","DMA is one restartable instruction: a fault exposes no event prefix or partial destination update; recovery performs a full reissue and one successful commit."],"standalone_opcode":true,"state_effects":["Snapshot both Reg5 address operands before access preflight so repeated GPR selectors and T/U queue sources observe pre-instruction values. DMA has no scalar destination and consumes no queue entry.","Successful execution advances TPC by four bytes after the complete memory and event commit. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.","GPRs, T/U queues, unrelated memory, and unrelated architectural state are unchanged. Reservation state changes only for a successful destination range overlapping the reserved 64-byte granule."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-DMA","mnemonic":"DMA","summary":"DMA performs an exact 64-byte copy, validates both ranges before effects, snapshots the source so overlap has memmove semantics, and guarantees that any fault leaves memory unchanged for precise full reissue.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DMA()
    => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DMA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;

pure func InstructionContractCopySizeBytes_DMA()
    => integer {1..262144}
begin
    return 64;
end;

pure func InstructionContractEventChunkSizeBytes_DMA()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractEventChunkCount_DMA()
    => integer {1..16}
begin
    return 8;
end;

pure func InstructionContractSourceProbePrecedesDestination_DMA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourceBeforeCommit_DMA()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
