// PTO-INSTRUCTION: {"assembly":["TLOAD <bundle operands>"],"block":["# Local form","BSTART.TLSU TLOAD","B.DATR/B.DIM","B.IOT","B.IOR","BSTOP","# Shared form","BSTART.TLSU TLOAD","B.DATR/B.DIM","B.IOS","B.IOR","BSTOP"],"catalog_indices":[87],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.TLOAD","function":0,"name":"TLOAD","semantic_handler":"TLOAD","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"}],"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"scalar0"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TLOAD","effect_contract":"TLOAD","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:address:base-address","operand:scalar0:row-stride-elements"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","regular"],"mnemonic":"TLOAD","summary":"Load the valid GM rectangle into a Tile using the encoded base and logical row stride.","surface":"tile","id":"PTO-TILE-TLOAD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..7}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;

readonly func InstructionContractGMAddress_TLOAD(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryIndexedAddress(base_address,
        TileMemoryStridedIndex(row, column, row_stride_elements), data_type);
end;
// DOC-END: operation
