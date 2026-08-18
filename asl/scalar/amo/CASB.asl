// PTO-INSTRUCTION: {"assembly":["casb [SrcL], SrcR, SrcD, ->Rd","casb.aq [SrcL], SrcR, SrcD, ->Rd","casb.rl [SrcL], SrcR, SrcD, ->Rd","casb.aqrl [SrcL], SrcR, SrcD, ->Rd"],"block":[],"catalog_indices":[50],"catalog_records":[{"asm":"casb<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x0000001b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"casb_32_7e529b871832","length_bits":32,"mnemonic":"CASB","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"CompareAndSwap","semantic_summary":"CASB atomically compares and conditionally replaces one byte, then publishes the prior value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["casb [SrcL], SrcR, SrcD, ->Rd","casb.aq [SrcL], SrcR, SrcD, ->Rd","casb.rl [SrcL], SrcR, SrcD, ->Rd","casb.aqrl [SrcL], SrcR, SrcD, ->Rd"],"defaults":["SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","The short form has no far field and therefore uses the default flat-address route."],"encoding_class":"standalone-encoded","examples":["casb [a0], a1, a2, ->a3","casb.aqrl [t#1], u#1, a0, ->u"],"exceptions":["Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.","On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the prior value.","SrcL":"Encoded zero reads the architectural zero register as the address.","SrcR":"Encoded zero supplies numeric zero as the expected value.","SrcD":"Encoded zero supplies numeric zero as the desired value.","aq":"Encoded zero disables acquire ordering.","rl":"Encoded zero disables release ordering."},"legality":["All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All aq and rl combinations are assigned; the short form has implicit far zero.","Every byte address is naturally aligned."],"memory_effects":["After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte and compare it with SrcR truncated to 1 bytes.","On equality, store SrcD truncated to 1 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.","Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.","The 8-bit old value is zero-extended to XLEN."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 expected byte source"},{"field":"SrcD","role":"Reg5 desired byte source"},{"field":"RegDst","role":"Reg5 old-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.","The short form always uses the default flat-address route."],"standalone_opcode":true,"state_effects":["Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.","Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.","The 8-bit old value is zero-extended to XLEN.","Successful execution advances TPC by 4 bytes. A fault saves and later restores the original TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-CASB","mnemonic":"CASB","summary":"CASB atomically compares and conditionally replaces one byte, then publishes the prior value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CASB() => ScalarOperation
begin
    return ScalarOperation_CASB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CASB() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_CASB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractHasFarField_CASB()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractZeroExtendsOldValue_CASB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_CASB()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
