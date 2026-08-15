// PTO-INSTRUCTION: {"assembly":["hl.casd [SrcL], SrcR, SrcD, ->Rd","hl.casd.aq [SrcL], SrcR, SrcD, ->Rd","hl.casd.rl [SrcL], SrcR, SrcD, ->Rd","hl.casd.f [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqrl [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqf [SrcL], SrcR, SrcD, ->Rd","hl.casd.rlf [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqrlf [SrcL], SrcR, SrcD, ->Rd"],"block":[],"catalog_indices":[132],"catalog_records":[{"asm":"hl.casd<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707ff83f","match":"0x3000600b000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_casd_48_fbb5c4256d30","length_bits":48,"mnemonic":"HL.CASD","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"CompareAndSwap","semantic_summary":"HL.CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["hl.casd [SrcL], SrcR, SrcD, ->Rd","hl.casd.aq [SrcL], SrcR, SrcD, ->Rd","hl.casd.rl [SrcL], SrcR, SrcD, ->Rd","hl.casd.f [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqrl [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqf [SrcL], SrcR, SrcD, ->Rd","hl.casd.rlf [SrcL], SrcR, SrcD, ->Rd","hl.casd.aqrlf [SrcL], SrcR, SrcD, ->Rd"],"defaults":["SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and atomic result."],"encoding_class":"standalone-encoded","examples":["hl.casd [a0], a1, a2, ->a3","hl.casd.aqrlf [t#1], u#1, a0, ->u"],"exceptions":["The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.","On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the prior value.","SrcL":"Encoded zero reads the architectural zero register as the address.","SrcR":"Encoded zero supplies numeric zero as the expected value.","SrcD":"Encoded zero supplies numeric zero as the desired value.","aq":"Encoded zero disables acquire ordering.","rl":"Encoded zero disables release ordering.","far":"Encoded zero selects the default flat-address route."},"legality":["All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All aq, rl, and far combinations are assigned.","The effective address must be aligned to 8 bytes."],"memory_effects":["After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.","On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.","Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.","The 64-bit old value is published unchanged."],"operands":[{"field":"SrcL","role":"Reg5 atomic address source"},{"field":"SrcR","role":"Reg5 expected doubleword source"},{"field":"SrcD","role":"Reg5 desired doubleword source"},{"field":"RegDst","role":"Reg5 old-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.","far changes only the route hint in the reference profile."],"standalone_opcode":true,"state_effects":["Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.","Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.","The 64-bit old value is published unchanged.","Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-HL-CASD","mnemonic":"HL.CASD","summary":"HL.CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_HL_CASD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
