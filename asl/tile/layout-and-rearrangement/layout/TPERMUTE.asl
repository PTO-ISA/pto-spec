// PTO-INSTRUCTION: {"assembly":["TPERMUTE <bundle operands>"],"block":["BSTART.SFU TPERMUTE, DataType","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source0, source1","B.IOT indices, ->destination","BSTOP"],"catalog_indices":[94],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TPERMUTE","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":21,"legality_handler":"TileOperandsLegal_TPERMUTE","mode":3,"name":"TPERMUTE","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"source2","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x075","semantic_handler":"TPERMUTE","state_effects":["operand:destination0:destination","operand:source0:source0","operand:source1:source1","operand:source2:indices"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TPERMUTE, DataType","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source0, source1","B.IOT indices, ->destination","BSTOP"],"canonical_assembly":["TPERMUTE <bundle operands>"],"defaults":["B.DATR has no effect other than selecting CUBE_M16 or CUBE_M32; padding and numeric fields remain zero.","A nonzero PE mask requires two ordered B.IOT bindings and no B.IOR."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TPERMUTE, U32; B.DATR Layout; B.IOT source0, source1; B.IOT indices, ->destination; BSTOP"],"exceptions":["Illegal raw indices reject before any destination effect with Fault_TileLegality.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TPERMUTE accepts only Local CUBE_M16 or CUBE_M32 data Tiles with matching dtype and geometry.","indices is Local U8 with the same CUBE layout and supplies one byte index for every valid destination byte.","The destination is fresh; source0 and source1 may alias, while indices is distinct from both sources.","Raw bytes are rearranged without numerical conversion."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"source2","role":"indices"}],"ordering":["All index legality and source reads precede destination publication."],"standalone_opcode":false,"state_effects":["Perform per-row two-source raw-byte table lookup and publish only the destination valid region."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TPERMUTE","mnemonic":"TPERMUTE","summary":"Permute raw bytes from two Local CUBE sources by a Local U8 index Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TPERMUTE-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TPERMUTE performs a two-source per-row raw-byte lookup over Local CUBE_M16
// or CUBE_M32 Cells. Every valid destination byte and its index are checked
// before the fresh destination is published; invalid indices reject atomically.
// NDF-END: PTO-TPERMUTE-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPERMUTE() => TileOperation
begin
    return TileOperation_TPERMUTE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPERMUTE() => TileSemanticHandler
begin
    return TileHandler_TPERMUTE;
end;

pure func InstructionContractDataTypeLegal_TPERMUTE(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           TileElementBits(data_type) != 64;
end;

readonly func InstructionContractOperandsLegal_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TPERMUTE(destination, source0, source1, indices);
end;

func InstructionContractExecute_TPERMUTE(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPERMUTE(
        destination, source0, source1, indices);
    TPERMUTE(destination, source0, source1, indices);
end;
// DOC-END: operation
