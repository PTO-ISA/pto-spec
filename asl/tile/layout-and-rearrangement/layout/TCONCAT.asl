// PTO-INSTRUCTION: {"assembly":["TCONCAT <bundle operands>"],"block":["BSTART.SFU TCONCAT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[68],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCONCAT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TCONCAT","mode":3,"name":"TCONCAT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x060","semantic_handler":"TCONCAT","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TCONCAT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"canonical_assembly":["TCONCAT <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TCONCAT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TCONCAT."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCONCAT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TCONCAT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TCONCAT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}]."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Concatenate two source Tiles along columns.","After complete preflight, execute TCONCAT with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TCONCAT","mnemonic":"TCONCAT","summary":"Concatenate two source Tiles along columns.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCONCAT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCONCAT MUST concatenate exactly two persistent Local sources along columns.
// It MUST NOT accept an axis operand or a vertical concatenation form.
// Complete source validation and snapshot MUST precede atomic destination
// payload, definedness, Null-padding, and descriptor publication.
// NDF-END: PTO-TCONCAT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCONCAT() => TileOperation
begin
    return TileOperation_TCONCAT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCONCAT() => TileSemanticHandler
begin
    return TileHandler_TCONCAT;
end;

pure func InstructionContractDataTypeLegal_TCONCAT(
    data_type: TileDataType) => boolean
begin
    return TileMove24DataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
end;

func InstructionContractExecute_TCONCAT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCONCAT(
        destination,
        source_left,
        source_right);
    TCONCAT(destination, source_left, source_right);
end;
// DOC-END: operation
