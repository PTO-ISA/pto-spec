// PTO-INSTRUCTION: {"assembly":["TINSERT <bundle operands>"],"block":["BSTART.SFU TINSERT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[70],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"natural0"},{"operand":"natural1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TINSERT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":3,"legality_handler":"TileOperandsLegal_TINSERT","mode":3,"name":"TINSERT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"persistent old destination"},{"field":"source1","role":"persistent insertion source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x063","semantic_handler":"TINSERT","state_effects":["operand:destination0:destination","operand:source0:persistent-old-destination","operand:source1:persistent-insertion-source","operand:natural0:row-offset","operand:natural1:column-offset"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TINSERT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","B.IOR","BSTOP"],"canonical_assembly":["TINSERT <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TINSERT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TINSERT."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TINSERT, DataType; B.DATR (optional); B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; B.IOR; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TINSERT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TINSERT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}].","The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"persistent old destination"},{"field":"source1","role":"persistent insertion source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Insert a source Tile into a snapshotted old destination region at the encoded row and column offsets.","After complete preflight, execute TINSERT with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TINSERT","mnemonic":"TINSERT","summary":"Insert a source Tile into a snapshotted old destination region at the encoded row and column offsets.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TINSERT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TINSERT MUST snapshot one persistent old destination and one persistent
// insertion source, then replace only the selected in-range result window.
// Uncovered payload and definedness MUST remain identical to the old
// destination, and the renamed result MUST publish atomically.
// The selected DataType MUST be a carrier interpretation. A non-packed source
// backing type MAY differ only at the same element width, and the renamed
// destination MUST preserve the source backing type.
// NDF-END: PTO-TINSERT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TINSERT() => TileOperation
begin
    return TileOperation_TINSERT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TINSERT() => TileSemanticHandler
begin
    return TileHandler_TINSERT;
end;

pure func InstructionContractDataTypeLegal_TINSERT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
end;

func InstructionContractExecute_TINSERT(
    destination: TileIndex,
    old_destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
    TINSERT(
        destination,
        old_destination,
        source,
        row_offset,
        column_offset);
end;
// DOC-END: operation
