// PTO-INSTRUCTION: {"assembly":["TFMA <bundle operands>"],"block":["BSTART.VEC TFMA, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOT","BSTOP"],"catalog_indices":[24],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TFMA","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":28,"legality_handler":"TileOperandsLegal_TFMA","mode":0,"name":"TFMA","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"multiplicand-left"},{"field":"source1","role":"multiplicand-right"},{"field":"source2","role":"addend"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01C","semantic_handler":"TFMA","state_effects":["operand:destination0:destination","operand:source0:multiplicand-left","operand:source1:multiplicand-right","operand:source2:addend"]}],"classification":["elementwise-tile-tile","arithmetic"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TFMA","mnemonic":"TFMA","summary":"Compute a fused elementwise left-times-right plus addend result.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractElement_TFMA(
    addend: Word, left: Word, right: Word,
    destination_type: TileDataType, left_type: TileDataType,
    right_type: TileDataType) => Word
begin
    return TileProfileMatrixAccumulate(addend, left, right,
        destination_type, left_type, right_type);
end;
// DOC-END: operation
