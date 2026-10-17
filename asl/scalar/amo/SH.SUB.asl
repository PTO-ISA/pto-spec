// PTO-INSTRUCTION: {"assembly":["sh.sub<.{rl}> [SrcL], SrcR"],"block":[],"catalog_indices":[472],"catalog_records":[{"asm":"sh.sub<.{rl}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xfc007fff","match":"0xc000500b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sh_sub_32_op5_v0587","length_bits":32,"mnemonic":"SH.SUB","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","semantic_summary":"SH.SUB atomically applies width-sized modular sub and does not publish the old value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["sh.sub [SrcL], SrcR","sh.sub.rl [SrcL], SrcR"],"defaults":["SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.","rl=0 selects relaxed ordering; rl=1 selects release ordering."],"encoding_class":"standalone-encoded","examples":["sh.sub [a0], a1","sh.sub.rl [t#1], u#1"],"exceptions":["Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.","If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.","An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero register as the atomic address.","SrcR":"Encoded zero supplies numeric zero as the atomic operand.","rl":"Encoded zero selects relaxed ordering."},"legality":["All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","The effective address must be aligned to 2 bytes. SrcL, SrcR, and rl have no reserved encodings in this form.","The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue."],"memory_effects":["Atomically read one aligned 2-byte little-endian value, compute the 16-bit modular difference, and write one 2-byte result to the same location.","Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.","On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 atomic operand source"},{"field":"rl","role":"release ordering bit"}],"ordering":["rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before any memory or architectural effect.","SH.SUB stores the 16-bit modular difference; it does not publish the old value.","Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"id":"PTO-SCALAR-SH-SUB","mnemonic":"SH.SUB","summary":"SH.SUB atomically applies width-sized modular sub and does not publish the old value.","surface":"scalar"}
// NDF-BEGIN: PTO-SH-SUB-CONTRACT-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Issue: https://github.com/PTO-ISA/pto-spec/issues/389
// SH.SUB MUST apply width-sized modular sub under the existing
// store-only RMW preflight, ordering, reservation, fault, and restart contract.
// NDF-END: PTO-SH-SUB-CONTRACT-001
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SH_SUB() => ScalarOperation
begin
    return ScalarOperation_SH_SUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SH_SUB()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SH_SUB()
    => AtomicOperation
begin
    return Atomic_SUB;
end;

pure func InstructionContractAtomicSizeBytes_SH_SUB()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractPublishesOldValue_SH_SUB()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
