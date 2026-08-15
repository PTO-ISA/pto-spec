// PTO-INSTRUCTION: {"assembly":["swapb [SrcL], SrcR, ->Rd","swapb.aq [SrcL], SrcR, ->Rd","swapb.rl [SrcL], SrcR, ->Rd","swapb.f [SrcL], SrcR, ->Rd","swapb.aqrl [SrcL], SrcR, ->Rd","swapb.aqf [SrcL], SrcR, ->Rd","swapb.rlf [SrcL], SrcR, ->Rd","swapb.aqrlf [SrcL], SrcR, ->Rd"],"block":[],"catalog_indices":[459],"catalog_records":[{"asm":"swapb<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x0000600b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"swapb_32_80733f03b77f","length_bits":32,"mnemonic":"SWAPB","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","semantic_summary":"SWAPB atomically replaces one byte and publishes the prior value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["swapb [SrcL], SrcR, ->Rd","swapb.aq [SrcL], SrcR, ->Rd","swapb.rl [SrcL], SrcR, ->Rd","swapb.f [SrcL], SrcR, ->Rd","swapb.aqrl [SrcL], SrcR, ->Rd","swapb.aqf [SrcL], SrcR, ->Rd","swapb.rlf [SrcL], SrcR, ->Rd","swapb.aqrlf [SrcL], SrcR, ->Rd"],"defaults":["SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result."],"encoding_class":"standalone-encoded","examples":["swapb [a0], a1, ->a2","swapb.aqrl [t#1], u#1, ->u","swapb.f [sp], zero, ->t"],"exceptions":["Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.","On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the prior value.","SrcL":"Encoded zero reads the architectural zero register as the address.","SrcR":"Encoded zero supplies numeric zero as the replacement.","aq":"Encoded zero disables acquire ordering.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero disables release ordering."},"legality":["All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All aq, rl, and far combinations are assigned.","Every byte address is naturally aligned."],"memory_effects":["After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte, store SrcR truncated to 1 bytes, and emit one ordered atomic event.","A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.","The 8-bit old value is zero-extended to XLEN."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 byte replacement source"},{"field":"RegDst","role":"Reg5 old-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.","far changes only the route hint in the reference profile."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before any memory or destination effect.","Publish the prior value only after successful atomic commit.","The 8-bit old value is zero-extended to XLEN.","Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SWAPB","mnemonic":"SWAPB","summary":"SWAPB atomically replaces one byte and publishes the prior value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SWAPB() => ScalarOperation
begin
    return ScalarOperation_SWAPB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SWAPB() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPB()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPB()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
