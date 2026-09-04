// PTO-INSTRUCTION: {"assembly":["TPREFETCH <bundle operands>"],"block":["BSTART.TPREFETCH DataType","B.DATR Layout (optional)","B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col (optional)","B.IOR base,row_stride (optional)","BSTOP"],"catalog_indices":[76],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"positive0"},{"operand":"positive1"},{"operand":"positive2"}],"command_mnemonic":"BSTART.TPREFETCH","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TPREFETCH","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":3,"legality_handler":"TileOperandsLegal_TPREFETCH","name":"TPREFETCH","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"},{"field":"positive0","role":"valid-columns"},{"field":"positive1","role":"valid-rows"},{"field":"positive2","role":"physical-columns"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TPREFETCH","state_effects":["operand:address:base-address","operand:scalar0:row-stride-elements","operand:positive0:valid-columns","operand:positive1:valid-rows","operand:positive2:physical-columns"]}],"classification":["memory-and-data-movement","regular"],"contract":{"block_composition":["BSTART.TPREFETCH DataType","B.DATR Layout (optional)","B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col (optional)","B.IOR base,row_stride (optional)","BSTOP"],"canonical_assembly":["TPREFETCH <bundle operands>"],"defaults":["Omitted B.DATR selects NORM; omitted LB0 and LB1 each select one, and omitted LB2 selects resolved ValidCol.","Omitted B.IOR supplies base zero and dense row stride equal to resolved Col for every PE. Explicit zero selectors remain actual zero values."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP"],"exceptions":["Malformed dimensions, unsupported data attributes, any B.IOT or B.IOS, or any memory fault in the combined four-PE footprint rejects before the first request or event.","A rejected or faulting attempt changes no Tile, Shared, descriptor, payload, definedness, or allocation state."],"field_contracts":{},"field_zero_meanings":{"address":"An explicitly selected zero GPR supplies base address zero.","scalar0":"An explicitly selected zero GPR supplies row stride zero."},"legality":["TPREFETCH is selected only by BSTART.TPREFETCH at TLSU Function 3 and has no standalone opcode.","It has implicit participation 1111 and accepts no Local or Shared Tile binding.","ValidCol and ValidRow are positive; Col is a nonzero power of two and is at least ValidCol.","B.DATR permits only Layout as a nonzero operation attribute and requires the pad union to remain zero."],"memory_effects":["For each PE, prefetch the same typed, strided ValidRow x ValidCol GM footprint that TLOAD would read from that PE's private base and row-stride GPR values.","The operation records TLOAD-equivalent typed-element load events but produces no destination. Cache placement and retention are not architecturally visible."],"operands":[{"field":"address","role":"per-PE GM base"},{"field":"scalar0","role":"per-PE logical row stride in elements"},{"field":"positive0","role":"ValidCol"},{"field":"positive1","role":"ValidRow"},{"field":"positive2","role":"physical Col"}],"ordering":["Preflight all addresses and permissions for all four PEs before any event.","Use CurrentBundleMemoryOrder so aq/rl and PTO-TSO behavior match TLOAD."],"standalone_opcode":false,"state_effects":["No destination Tile exists and no Tile or Shared state changes.","A successful attempt contributes only its typed memory-access and ordering events."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TPREFETCH","mnemonic":"TPREFETCH","summary":"Prefetches a typed, strided GM rectangle for all four PEs without producing a Tile destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TPREFETCH-FOOTPRINT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TPREFETCH MUST use TLOAD-equivalent typed address generation and events for
// all four PE-private base/stride inputs and MUST NOT allocate or write a Tile.
// NDF-END: PTO-TPREFETCH-FOOTPRINT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPREFETCH() => TileOperation
begin
    return TileOperation_TPREFETCH;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TPREFETCH(
    code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TPREFETCH() => TileSemanticHandler
begin
    return TileHandler_TPREFETCH;
end;

pure func InstructionContractPublishesTileDestination_TPREFETCH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesTLOADFootprint_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
