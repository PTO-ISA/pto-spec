// PTO-INSTRUCTION: {"assembly":["lr.w [SrcL], ->Rd","lr.w.aq [SrcL], ->Rd","lr.w.rl [SrcL], ->Rd","lr.w.f [SrcL], ->Rd","lr.w.aqrl [SrcL], ->Rd","lr.w.aqf [SrcL], ->Rd","lr.w.rlf [SrcL], ->Rd","lr.w.aqrlf [SrcL], ->Rd"],"block":[],"catalog_indices":[337],"catalog_records":[{"asm":"lr.w<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x2000000b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcZero","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"lr_w_32_efecc735bb75","length_bits":32,"mnemonic":"LR.W","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"LoadReserved","semantic_summary":"LR.W loads one word, establishes a 64-byte-line reservation, and publishes the prior value.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["lr.w [SrcL], ->Rd","lr.w.aq [SrcL], ->Rd","lr.w.rl [SrcL], ->Rd","lr.w.f [SrcL], ->Rd","lr.w.aqrl [SrcL], ->Rd","lr.w.aqf [SrcL], ->Rd","lr.w.rlf [SrcL], ->Rd","lr.w.aqrlf [SrcL], ->Rd"],"defaults":["SrcL and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the loaded value.","SrcZero is an ignored alias field. Every encoding 0..31 selects the same operation and no register or queue is read through SrcZero.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and reservation behavior."],"encoding_class":"standalone-encoded","examples":["lr.w [a0], ->a1","lr.w.aqrl [t#1], ->u","lr.w.f [sp], ->t"],"exceptions":["The effective address must be aligned to 4 bytes. Alignment, translation, and read permission are checked before effects and report the original address.","On a fault, no destination or queue value is published, no memory event is emitted, the prior reservation is preserved, and TPC does not advance. Trap entry saves the original TPC and recovery restores it for full reissue.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. SrcZero, aq, rl, far, and all Reg5 values have no reserved encodings."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the loaded value.","SrcL":"Encoded zero reads the architectural zero register as the load address.","SrcZero":"Encoded zero is one of 32 ignored aliases and supplies no operand.","aq":"Encoded zero disables acquire ordering.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero disables release ordering."},"legality":["All 32 SrcL Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All 32 SrcZero encodings are ignored aliases. All aq, rl, and far combinations are assigned.","The effective address must be aligned to 4 bytes."],"memory_effects":["Read one 4-byte little-endian word after complete access preflight and record one ordered load event at the translated address.","After a successful load, replace any prior local reservation with the original address and width 4; SC matching uses the containing 64-byte reservation granule.","The 32-bit old value is sign-extended to XLEN."],"operands":[{"field":"SrcL","role":"Reg5 load address source"},{"field":"SrcZero","role":"ignored 5-bit alias field"},{"field":"RegDst","role":"Reg5 loaded-value destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.","far changes only the route hint in the reference profile and does not change the address, event order, loaded value, or reservation."],"standalone_opcode":true,"state_effects":["Snapshot SrcL before any memory, reservation, or destination effect. SrcZero is not read.","On success, publish the word old value only after the load completes and establish the 64-byte-line reservation.","The 32-bit old value is sign-extended to XLEN.","Successful execution advances TPC by four bytes. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-LR-W","mnemonic":"LR.W","summary":"LR.W loads one word, establishes a 64-byte-line reservation, and publishes the prior value.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LR_W() => ScalarOperation
begin
    return ScalarOperation_LR_W;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LR_W() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;

pure func InstructionContractLoadSizeBytes_LR_W()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractIgnoresSrcZero_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsResult_LR_W()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsResult_LR_W()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractReservationGranuleBytes_LR_W()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;
// DOC-END: operation
