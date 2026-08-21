// PTO-INSTRUCTION: {"assembly":["B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><SizeCode>"],"block":[],"catalog_indices":[52],"catalog_records":[{"asm":"B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><SizeCode>","constraints":[{"field":"SizeCode","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12]},{"field":"PEMode","operator":"one-of","values":[0,1,2,3,4,5,6,7]}],"encoding":[{"index":0,"mask":"0xf00871ff","match":"0x00001013","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SharedTID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":8}],"signedness":"encoding-defined","width":8},{"name":"SizeCode","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"PEMode","pieces":[{"instruction_lsb":9,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"b_ios_32_4ba5ef98fdaa","length_bits":32,"mnemonic":"B.IOS","semantic_family":"CMD","semantic_group":"Bundle Input & Output","semantic_handler":"BindBundleSharedIO","semantic_summary":"Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mode decoded to a fixed mask.","status":"accepted"}],"classification":["operands"],"contract":{"block_composition":["Header command after BSTART and before the first body instruction. A block may contain zero to four effective B.IOS instructions, ordered according to the selected operation schema."],"canonical_assembly":["B.IOS S<SharedTID>, mask=<PE_MASK> | B.IOS mask=<PE_MASK>, ->S<SharedTID><SizeCode>"],"defaults":["S0 is an ordinary absolute Shared-register name. SizeCode=0 selects the source form; SizeCode=1..12 selects a destination capacity of 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, or 256 KiB per participating PE. Codes 13..15 are reserved.","PEMode is a three-bit encoding expanded by the common profile decoder to the fixed four-PE semantic mask: 000 none, 001 PE0, 010 PE1, 011 PE2, 100 PE3, 101 PE0+PE1, 110 PE0+PE1+PE2, and 111 all four PEs.","PEMode=000 decodes to no participating PE and is a strict no-op before placement, duplicate, schema, allocation, descriptor, memory, and downstream fault checks."],"encoding_class":"standalone-encoded","examples":["B.IOS S1, mask=0011","B.IOS mask=1111, ->S255<0001>"],"exceptions":["Reserved instruction bits, SizeCode 13..15, and malformed field combinations raise Fault_IllegalInstruction before architectural effects.","A participating B.IOS outside an active header, a duplicate SharedTID, or a fifth effective binding raises Illegal Block Exception before changing the stream.","A mismatched effective decoded PE mask, incompatible destination descriptor, mask expansion, or operation-schema role mismatch raises Fault_TileLegality before Shared state changes.","PEMode=000 is a strict no-op and cannot raise a downstream schema, duplicate, allocation, descriptor, or memory fault."],"field_contracts":{},"field_zero_meanings":{"SharedTID":"Encoded zero names S0; it does not mean absence.","SizeCode":"Encoded zero selects a Shared source and never allocates.","PEMode":"Encoded zero decodes to mask 0000 and makes B.IOS a strict no-op."},"legality":["All SharedTID codes 0..255 are assigned absolute Core-private Shared-register names S0..S255.","SizeCode code 0 is the source role; destination codes 1..12 encode 128 B, 256 B, 512 B, 1 KiB, 2 KiB, 4 KiB, 8 KiB, 16 KiB, 32 KiB, 64 KiB, 128 KiB, and 256 KiB per participating PE. Codes 13..15 are reserved.","The three-bit PEMode field accepts all eight encodings and the common profile decoder expands them exactly to the fixed four-PE semantic mask table. PEMode=000 is the strict no-effect source-bearing encoding.","A participating B.IOS is legal only after BSTART and before the block body. At most four effective Shared bindings are accepted in encoded order.","Two effective bindings in one block may not name the same Sx. The selected operation schema determines each ordered Shared operand role and must agree with SizeCode source/destination encoding."],"memory_effects":["none"],"operands":[{"field":"SharedTID","role":"absolute Core-private Shared register S0 through S255, visible to all four PEs of that core"},{"field":"SizeCode","role":"role and capacity: 0 source; 1..12 destination with 128 B..256 KiB per participating PE"},{"field":"PEMode","role":"three-bit encoded participation mode expanded by the common decoder to a four-PE semantic mask"}],"ordering":["Effective B.IOS bindings form one encoded-order stream of at most four operands. The selected operation consumes the stream in schema order.","The architecture imposes no ordering between conflicting PE accesses to Shared payload offsets; software avoids conflicts or establishes separate synchronization."],"standalone_opcode":true,"state_effects":["The common PE-mode decoder expands PEMode once to the semantic four-PE mask used by every effective Shared binding.","A zero decoded mask is a strict no-op. A source binding is read-only and never changes its Shared descriptor, allocation mask, initialized mask, or payload.","A successful destination atomically updates selected payload quarters and a compatible persistent descriptor; its first write fixes the allocation mask and later writes cannot expand it."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-B-IOS","mnemonic":"B.IOS","summary":"Binds one ordered absolute Core-private Shared register S0..S255 as a source or destination with a common four-PE participation mode decoded to a fixed mask.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-B-IOS-SHARED-STATE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.IOS MUST bind absolute S0..S255 state, MUST decode PEMode=000 as a strict
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
    size_code: integer {0..12}) => boolean
begin
    return size_code == 0;
end;

pure func InstructionContractPerPECapacity_B_IOS(
    size_code: integer {1..12}) => integer
begin
    return TileSizeCodeBytes(size_code);
end;

pure func InstructionContractCoreCapacity_B_IOS(
    size_code: integer {1..12}, pe_mask: bits(4)) => integer
begin
    return TileCoreAllocationBytes(pe_mask,
        InstructionContractPerPECapacity_B_IOS(size_code));
end;

readonly func InstructionContractHandler_B_IOS() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleSharedIO;
end;
// DOC-END: operation
