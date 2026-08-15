// PTO-INSTRUCTION: {"assembly":["B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>"],"block":[],"catalog_indices":[52],"catalog_records":[{"asm":"B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>","constraints":[],"encoding":[{"index":0,"mask":"0xf00871ff","match":"0x00001013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SharedTID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":8}],"signedness":"encoding-defined","width":8},{"name":"PE_MASK","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"TSize","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"b_ios_32_4ba5ef98fdaa","length_bits":32,"mnemonic":"B.IOS","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleSharedIO","semantic_summary":"Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mask.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Header command after BSTART and before the first body instruction. A block may contain zero to four effective B.IOS instructions, ordered according to the selected operation schema."],"canonical_assembly":["B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><TSize>"],"defaults":["S0 is an ordinary absolute Shared-register name. TSize=0 selects the source form; TSize=1..7 selects a destination capacity of 128 B..8 KiB per participating PE.","PE_MASK=0000 is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks."],"encoding_class":"standalone-encoded","examples":["B.IOS S1, mask=0011","B.IOS mask=1111, ->S255<001>"],"exceptions":["Reserved instruction bits raise Fault_IllegalInstruction before architectural effects.","A participating B.IOS outside an active header, a duplicate SharedTID, or a fifth effective binding raises Illegal Block Exception before changing the stream.","A mismatched effective PE_MASK, incompatible destination descriptor, mask expansion, or operation-schema role mismatch raises Fault_TileLegality before Shared state changes.","PE_MASK zero is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault."],"field_contracts":{},"field_zero_meanings":{"SharedTID":"Encoded zero names S0; it does not mean absence.","PE_MASK":"Encoded zero selects no participating PE and makes B.IOS a strict no-op.","TSize":"Encoded zero selects a Shared source; codes 1..7 select a Shared destination and its per-PE capacity."},"legality":["All SharedTID codes 0..255 are assigned absolute Core-private Shared-register names S0..S255.","TSize code 0 is the source role; destination codes 1..7 encode 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, and 8 KiB per participating PE.","PE_MASK is a four-PE predicate and multiple bits are legal. Every effective Shared and Local binding in the block uses the same nonzero mask unless the selected operation is stricter.","A participating B.IOS is legal only after BSTART and before the block body. At most four effective Shared bindings are accepted in encoded order.","Two effective bindings in one block may not name the same Sx. The selected operation schema determines each ordered Shared operand role and must agree with TSize source/destination encoding."],"memory_effects":["none"],"operands":[{"field":"SharedTID","role":"absolute Core-private Shared register S0 through S255, visible to all four PEs of that core"},{"field":"PE_MASK","role":"four-PE predicate common to every effective Local and Shared binding in the block"},{"field":"TSize","role":"role and capacity: 0 source; 1..7 destination with 128 B..8 KiB per participating PE"}],"ordering":["Effective B.IOS bindings form one encoded-order stream of at most four operands. The selected operation consumes the stream in schema order.","The architecture imposes no ordering between conflicting PE accesses to Shared payload offsets; software avoids conflicts or establishes separate synchronization."],"standalone_opcode":true,"state_effects":["Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mask.","A source binding is read-only and never changes its Shared descriptor, allocation mask, initialized mask, or payload. An uninitialized source supplies undefined-register values through a temporary operation-derived descriptor without allocating Sx.","A successful destination atomically updates selected payload quarters and a compatible persistent descriptor; the selected operation defines whether the aggregate Shared value is published. Its first write fixes the allocation mask; later writes may update only a subset with a compatible descriptor and cannot expand the mask."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-B-IOS","mnemonic":"B.IOS","summary":"Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mask.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-IOS-SHARED-STATE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.IOS MUST bind absolute S0..S255 state, MUST treat a zero mask as a strict
// no-op, and MUST update destination descriptor and selected payload quarters
// atomically. The selected operation MUST define publication separately.
// Reading an uninitialized source MUST be non-mutating and undefined.
// NDF-END: PTO-B-IOS-SHARED-STATE-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_IOS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ios_32_4ba5ef98fdaa);
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractSharedIsSource_B_IOS(
    size_code: integer {0..7}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractPerPECapacity_B_IOS(
    size_code: integer {1..7}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..7}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOS(size_code));
end;

readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
// DOC-END: operation
