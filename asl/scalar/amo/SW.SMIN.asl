// PTO-INSTRUCTION: {"assembly":["sw.smin<.{rl, f, rlf}> [SrcL], SrcR"],"block":[],"catalog_indices":[454],"catalog_records":[{"asm":"sw.smin<.{rl, f, rlf}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xf4007fff","match":"0x5000300b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sw_smin_32_773e7d83b011","length_bits":32,"mnemonic":"SW.SMIN","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","semantic_summary":"SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["sw.smin [SrcL], SrcR","sw.smin.rl [SrcL], SrcR","sw.smin.f [SrcL], SrcR","sw.smin.rlf [SrcL], SrcR"],"defaults":["SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.","rl=0 selects relaxed ordering; rl=1 selects release ordering.","far=0 selects the default flat-address route. far=1 is a routing hint and does not change the architectural address or atomic operation in the reference profile."],"encoding_class":"standalone-encoded","examples":["sw.smin [a0], a1","sw.smin.rl [t#1], u#1","sw.smin.f [sp], a0"],"exceptions":["Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.","If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.","An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects."],"field_contracts":{},"field_zero_meanings":{"SrcL":"Encoded zero reads the architectural zero register as the atomic address.","SrcR":"Encoded zero supplies numeric zero as the atomic operand.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero selects relaxed ordering."},"legality":["All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","The effective address must be aligned to 4 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.","The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue."],"memory_effects":["Atomically read one aligned 4-byte little-endian value, compute the signed minimum, and write one 4-byte result to the same location.","Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.","On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 atomic operand source"},{"field":"far","role":"flat-address routing hint"},{"field":"rl","role":"release ordering bit"}],"ordering":["rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.","far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before any memory or architectural effect.","SW.SMIN compares both values as two's-complement signed integers and selects the smaller value at 32-bit width and stores that value; it does not publish the old value.","Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SW-SMIN","mnemonic":"SW.SMIN","summary":"SW.SMIN atomically replaces the aligned 32-bit memory value with its signed minimum with SrcR; it does not publish the old value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW_SMIN() => ScalarOperation
begin
    return ScalarOperation_SW_SMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW_SMIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_SMIN()
    => AtomicOperation
begin
    return Atomic_SMIN;
end;

pure func InstructionContractAtomicSizeBytes_SW_SMIN()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_SMIN()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
