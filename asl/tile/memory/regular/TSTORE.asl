// PTO-INSTRUCTION: {"assembly":["TSTORE <bundle operands>"],"block":["# Local form","BSTART.TLSU TSTORE","B.DATR/B.DIM","B.IOT","B.IOR","BSTOP","# Shared full form","BSTART.TLSU Function 1","B.IOS","B.IOR","BSTOP","# Shared pe_scope form","BSTART.TLSU Function 14","B.IOS","B.IOR","BSTOP"],"catalog_indices":[88],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.TSTORE","function":1,"name":"TSTORE","semantic_handler":"TSTORE","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"},{"field":"source0","role":"source"}],"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TSTORE","effect_contract":"TSTORE","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:address:base-address","operand:scalar0:row-stride-elements","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","regular"],"mnemonic":"TSTORE","summary":"Store the valid Tile rectangle to GM using the encoded base and logical row stride.","surface":"tile","id":"PTO-TILE-TSTORE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryIndexedAddress(base_address,
        TileMemoryStridedIndex(row, column, row_stride_elements), data_type);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;
// DOC-END: operation
