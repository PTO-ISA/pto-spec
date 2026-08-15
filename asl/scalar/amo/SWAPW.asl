// PTO-INSTRUCTION: {"assembly":["swapw [SrcL], SrcR, ->Rd","swapw.aq [SrcL], SrcR, ->Rd","swapw.rl [SrcL], SrcR, ->Rd","swapw.f [SrcL], SrcR, ->Rd","swapw.aqrl [SrcL], SrcR, ->Rd","swapw.aqf [SrcL], SrcR, ->Rd","swapw.rlf [SrcL], SrcR, ->Rd","swapw.aqrlf [SrcL], SrcR, ->Rd"],"block":[],"catalog_indices":[462],"catalog_records":[{"asm":"swapw<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x2000600b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"swapw_32_ef15c3ebac33","length_bits":32,"mnemonic":"SWAPW","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","semantic_summary":"SWAPW atomically replaces one word and publishes the prior value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["swapw [SrcL], SrcR, ->Rd","swapw.aq [SrcL], SrcR, ->Rd","swapw.rl [SrcL], SrcR, ->Rd","swapw.f [SrcL], SrcR, ->Rd","swapw.aqrl [SrcL], SrcR, ->Rd","swapw.aqf [SrcL], SrcR, ->Rd","swapw.rlf [SrcL], SrcR, ->Rd","swapw.aqrlf [SrcL], SrcR, ->Rd"],"defaults":["SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result."],"encoding_class":"standalone-encoded","examples":["swapw [a0], a1, ->a2","swapw.aqrl [t#1], u#1, ->u","swapw.f [sp], zero, ->t"],"exceptions":["The effective address must be aligned to 4 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.","On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the prior value.","SrcL":"Encoded zero reads the architectural zero register as the address.","SrcR":"Encoded zero supplies numeric zero as the replacement.","aq":"Encoded zero disables acquire ordering.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero disables release ordering."},"legality":["All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All aq, rl, and far combinations are assigned.","The effective address must be aligned to 4 bytes."],"memory_effects":["After aligned read and write preflight identify the same translated location, atomically read one 4-byte word, store SrcR truncated to 4 bytes, and emit one ordered atomic event.","A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.","The 32-bit old value is sign-extended to XLEN."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 word replacement source"},{"field":"RegDst","role":"Reg5 old-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.","far changes only the route hint in the reference profile."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before any memory or destination effect.","Publish the prior value only after successful atomic commit.","The 32-bit old value is sign-extended to XLEN.","Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SWAPW","mnemonic":"SWAPW","summary":"SWAPW atomically replaces one word and publishes the prior value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SWAPW() => ScalarOperation
begin
    return ScalarOperation_SWAPW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SWAPW() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPW()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPW()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
