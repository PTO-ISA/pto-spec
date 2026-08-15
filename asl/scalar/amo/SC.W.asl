// PTO-INSTRUCTION: {"assembly":["sc.w SrcL, [SrcR], ->Rd","sc.w.aq SrcL, [SrcR], ->Rd","sc.w.rl SrcL, [SrcR], ->Rd","sc.w.f SrcL, [SrcR], ->Rd","sc.w.aqrl SrcL, [SrcR], ->Rd","sc.w.aqf SrcL, [SrcR], ->Rd","sc.w.rlf SrcL, [SrcR], ->Rd","sc.w.aqrlf SrcL, [SrcR], ->Rd"],"block":[],"catalog_indices":[391],"catalog_records":[{"asm":"sc.w<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x2000100b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sc_w_32_14b238f02bfd","length_bits":32,"mnemonic":"SC.W","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"StoreConditional","semantic_summary":"SC.W conditionally stores one word when the local 64-byte-line reservation matches.","status":"accepted"}],"classification":["amo"],"contract":{"block_composition":["none"],"canonical_assembly":["sc.w SrcL, [SrcR], ->Rd","sc.w.aq SrcL, [SrcR], ->Rd","sc.w.rl SrcL, [SrcR], ->Rd","sc.w.f SrcL, [SrcR], ->Rd","sc.w.aqrl SrcL, [SrcR], ->Rd","sc.w.aqf SrcL, [SrcR], ->Rd","sc.w.rlf SrcL, [SrcR], ->Rd","sc.w.aqrlf SrcL, [SrcR], ->Rd"],"defaults":["SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the status.","aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.","far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and reservation comparison."],"encoding_class":"standalone-encoded","examples":["sc.w a0, [a1], ->a2","sc.w.aqrl t#1, [u#1], ->u","sc.w.f zero, [sp], ->t"],"exceptions":["A line-matched effective address must be aligned to 4 bytes. On a line-matched attempt, alignment, translation, and write permission are checked after reservation clear and before memory or destination effects.","A line-matched access fault reports the original address, emits no event, preserves memory and destination, and enters the ordinary trap envelope. Recovery restores the original TPC.","A reservation miss is probe-free even for a misaligned or inaccessible address and therefore does not raise a data-access fault.","An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned."],"field_contracts":{},"field_zero_meanings":{"RegDst":"Encoded zero discards the success status.","SrcL":"Encoded zero supplies numeric zero as the store value.","SrcR":"Encoded zero reads the architectural zero register as the store address.","aq":"Encoded zero disables acquire ordering.","far":"Encoded zero selects the default flat-address route.","rl":"Encoded zero disables release ordering."},"legality":["All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.","All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.","All aq, rl, and far combinations are assigned. Reservation match is based only on the containing 64-byte line; LR byte address and width do not narrow it.","A line-matched effective address must be aligned to 4 bytes."],"memory_effects":["A matching reservation is cleared before access preflight. After successful preflight, store SrcL bits 31:0 as one 4-byte little-endian word, emit one ordered store event, and publish status zero.","A missing or different-line reservation is cleared and publishes status one without alignment, translation, permission, bounded-memory probe, memory event, or memory access.","The reservation is cleared by every attempt. A line-matched access fault leaves memory and destination unchanged; after recovery, reissue without a new LR is a probe-free miss."],"operands":[{"field":"SrcL","role":"Reg5 word store-value source"},{"field":"SrcR","role":"Reg5 store-address source"},{"field":"RegDst","role":"Reg5 success-status destination"},{"field":"aq","role":"acquire ordering bit"},{"field":"rl","role":"release ordering bit"},{"field":"far","role":"flat-address routing hint"}],"ordering":["aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release on a successful store.","A reservation miss emits no memory event. far changes only the route hint in the reference profile."],"standalone_opcode":true,"state_effects":["Snapshot SrcL and SrcR before reservation, memory, or destination effects, including repeated GPR and same-queue aliases.","Publish status zero after a nonfaulting matching store and status one after a reservation miss. A line-matched fault publishes no status.","Clear the local reservation for success, miss, and line-matched fault before any possible trap.","Successful or miss completion advances TPC by four bytes. A line-matched fault saves the original TPC; recovery restores it, and reissue without a new LR completes as a miss."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-SCALAR-SC-W","mnemonic":"SC.W","summary":"SC.W conditionally stores one word when the local 64-byte-line reservation matches.","surface":"scalar"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SC_W() => ScalarOperation
begin
    return ScalarOperation_SC_W;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SC_W() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;

pure func InstructionContractStoreSizeBytes_SC_W()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractReservationGranuleBytes_SC_W()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;

pure func InstructionContractSuccessStatus_SC_W() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractMissStatus_SC_W() => Word
begin
    return Zeros{PTO_XLEN} + 1;
end;

pure func InstructionContractMissIsProbeFree_SC_W()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
