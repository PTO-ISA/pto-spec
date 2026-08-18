// PTO-INSTRUCTION: {"assembly":["TTRANS <bundle operands>"],"block":["BSTART.SFU TTRANS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[80],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TTRANS","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":14,"legality_handler":"TileOperandsLegal_TTRANS","mode":3,"name":"TTRANS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06E","semantic_handler":"TTRANS","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TTRANS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"canonical_assembly":["TTRANS <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TTRANS schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TTRANS."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TTRANS, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TTRANS is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TTRANS validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}]."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Transpose the source Tile into the destination.","After complete preflight, execute TTRANS with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TTRANS","mnemonic":"TTRANS","summary":"Transpose the source Tile into the destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TTRANS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TTRANS MUST map every defined source coordinate [r,c] to destination [c,r]
// without changing its element encoding.
// Complete shape, type, layout, capacity, and definedness preflight MUST
// precede atomic transposed-result and Null-padding publication.
// NDF-END: PTO-TTRANS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TTRANS() => TileOperation
begin
    return TileOperation_TTRANS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TTRANS() => TileSemanticHandler
begin
    return TileHandler_TTRANS;
end;

pure func InstructionContractDataTypeLegal_TTRANS(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TTRANS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TTRANS(destination, source);
end;

func InstructionContractExecute_TTRANS(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TTRANS(destination, source);
    TTRANS(destination, source);
end;
// DOC-END: operation
