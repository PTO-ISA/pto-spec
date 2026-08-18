// PTO-INSTRUCTION: {"assembly":["ld.xor [SrcL], SrcR, ->Rd","ld.xor.aq [SrcL], SrcR, ->Rd","ld.xor.rl [SrcL], SrcR, ->Rd","ld.xor.f [SrcL], SrcR, ->Rd","ld.xor.aqrl [SrcL], SrcR, ->Rd","ld.xor.aqf [SrcL], SrcR, ->Rd","ld.xor.rlf [SrcL], SrcR, ->Rd","ld.xor.aqrlf [SrcL], SrcR, ->Rd"],"block":[],"catalog_indices":[323],"catalog_records":[{"asm":"ld.xor<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x3000400b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"ld_xor_32_33072c0fde61","length_bits":32,"mnemonic":"LD.XOR","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","semantic_summary":"LD.XOR atomically stores the width-sized bitwise XOR and publishes the prior memory value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["ld.xor [SrcL], SrcR, ->Rd","ld.xor.aq [SrcL], SrcR, ->Rd","ld.xor.rl [SrcL], SrcR, ->Rd","ld.xor.f [SrcL], SrcR, ->Rd","ld.xor.aqrl [SrcL], SrcR, ->Rd","ld.xor.aqf [SrcL], SrcR, ->Rd","ld.xor.rlf [SrcL], SrcR, ->Rd","ld.xor.aqrlf [SrcL], SrcR, ->Rd"],"defaults":["SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the published old value.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result."],"encoding_class":"standalone-encoded","examples":["ld.xor [a0], a1, ->a2","ld.xor.aqrl [t#1], u#1, ->t","ld.xor.f [sp], a0, ->u"],"exceptions":["The effective address must be aligned to 8 bytes. Alignment, translation, and permission checks occur before effects in that precedence order and report the original address.","Read and write access probes both complete before the memory load or store, and both probes must resolve to the same translated address.","On a fault, the instruction publishes no destination, performs no load, store, event, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores that TPC for full reissue.","An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the published old value.","SrcL":"Encoded zero reads the architectural zero register as the atomic address.","SrcR":"Encoded zero supplies numeric zero as the atomic operand.","aq":"Encoded zero disables acquire ordering.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero disables release ordering."},"legality":["All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 Reg5 destination encodings are assigned. Destination code 0 and destination codes 24..29 discard. Destination code 30 pushes U, destination code 31 pushes T, and codes 1..23 write the named absolute GPR.","The effective address must be aligned to 8 bytes. aq, rl, and far have no reserved combinations."],"memory_effects":["Atomically read one aligned 8-byte little-endian value, compute the width-sized bitwise XOR, and write one 8-byte result to the same location.","On success, record one atomic memory event. A completed overlapping write invalidates the overlapping local reservation; a nonoverlapping reservation remains valid.","The published result is the unchanged 64-bit old value."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 atomic operand source"},{"field":"RegDst","role":"Reg5 old-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.","far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before every memory or destination effect, so GPR and T/U source aliases observe the pre-instruction values.","LD.XOR computes the bitwise XOR at 64-bit width and publishes the prior memory value only after a successful atomic commit.","The published result is the unchanged 64-bit old value.","Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LD-XOR","mnemonic":"LD.XOR","summary":"LD.XOR atomically stores the width-sized bitwise XOR and publishes the prior memory value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LD_XOR() => ScalarOperation
begin
    return ScalarOperation_LD_XOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LD_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_LD_XOR()
    => AtomicOperation
begin
    return Atomic_XOR;
end;

pure func InstructionContractAtomicSizeBytes_LD_XOR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractPublishesOldValue_LD_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_LD_XOR()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
