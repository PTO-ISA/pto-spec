// PTO-INSTRUCTION: {"assembly":["GMOV <bundle operands>"],"block":["BSTART.GMOV DataType","B.DATR Layout (optional)","B.IOT source, destination, PE_MASK, TSize, L=1","B.IOR peer_tid (optional)","BSTOP"],"catalog_indices":[81],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.GMOV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"GMOV","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_GMOV","name":"GMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"resolved-peer-source"},{"field":"scalar0","role":"peer-tid"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GMOV","state_effects":["operand:destination0:destination","operand:source0:resolved-peer-source","operand:scalar0:peer-tid"]}],"classification":["memory-and-data-movement","pe-movement"],"contract":{"block_composition":["BSTART.GMOV DataType","B.DATR Layout (optional)","B.IOT source, destination, PE_MASK, TSize, L=1","B.IOR peer_tid (optional)","BSTOP"],"canonical_assembly":["GMOV <bundle operands>"],"defaults":["Omitted B.DATR selects NORM.","Omitted B.IOR supplies peer_tid zero in each PE; an explicit zero selector reads the zero GPR and is not absence."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.GMOV U8; B.IOT T#1, mask=0101, size=1, ->T; B.IOR zero, a0; BSTOP"],"exceptions":["Reject incompatible source/destination capacity, shape, type, layout, location, incomplete Core4 source readiness, peer_tid outside 0..3 in any PE, nonterminating or surplus bindings, B.DIM, or B.IOS before effects.","A failed collective preflight allocates and writes no destination."],"field_contracts":{},"field_zero_meanings":{"scalar0":"Zero selects peer PE 0."},"legality":["GMOV is TLSU Function 13 and has no standalone opcode.","Exactly one terminating Local source-plus-destination B.IOT is required. Its destination TSize equals the source per-PE capacity.","Any nonzero PE_MASK is legal; it selects destination writes but not rendezvous or source readiness. Mask zero is a strict no-op.","All four peer-resolved source fragments are ready before any selected request; each private peer_tid is 0..3 and may repeat."],"memory_effects":["none; GMOV neither accesses global memory nor emits load, store, atomic, or fence events"],"operands":[{"field":"destination0","role":"selected Local destination fragments"},{"field":"source0","role":"Core4 peer-resolved read-old Local source snapshot"},{"field":"scalar0","role":"each PE's absolute peer_tid"}],"ordering":["Combined Core4 rendezvous, descriptor, readiness, and peer validation precedes destination allocation and payload publication.","The source payload and definedness are snapshotted before any destination write."],"standalone_opcode":false,"state_effects":["Copies the byte-preserving resolved source fragment into each selected PE's newly allocated Local destination and copies definedness.","Unselected destinations and all Shared/GM state remain unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-GMOV","mnemonic":"GMOV","summary":"Copies peer-resolved Local fragments within a Core4 collective.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-GMOV-CORE4-PEER-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// GMOV MUST complete Core4 source readiness before effects. Each selected PE
// reads the Local fragment chosen by its private peer_tid and writes only its
// same-index Local destination; partial PE masks are legal and mask zero is a
// strict no-op. GMOV MUST NOT access Shared tile state.
// NDF-END: PTO-GMOV-CORE4-PEER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_GMOV(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;

pure func InstructionContractRequiresCoreFourReadiness_GMOV()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractPartialMaskWritesSelectedPEs_GMOV()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
