// PTO-INSTRUCTION: {"assembly":["TUNPACK <bundle operands>"],"block":["BSTART.SFU TUNPACK, U32","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source, ->destination","B.IOR unpack_control","BSTOP"],"catalog_indices":[106],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TUNPACK","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":24,"legality_handler":"TileOperandsLegal_TUNPACK","mode":3,"name":"TUNPACK","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"unpack-control"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x078","semantic_handler":"TUNPACK","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:unpack-control"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TUNPACK, U32","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source, ->destination","B.IOR unpack_control","BSTOP"],"canonical_assembly":["TUNPACK <bundle operands>"],"defaults":["A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TUNPACK, U32; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP"],"exceptions":["Illegal offset/count fields reject with Fault_TileLegality before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TUNPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.","The control selects one contiguous byte field with offset 0..3 and count 1..4 within a U32 word.","The result is zero-extended raw extraction."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"unpack-control"}],"ordering":["Control and source validation precede destination publication."],"standalone_opcode":false,"state_effects":["Extract and zero-extend one byte field in each active CUBE word group."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TUNPACK","mnemonic":"TUNPACK","summary":"Extract and zero-extend a raw byte field from Local U32 CUBE words.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TUNPACK-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TUNPACK extracts one contiguous byte field from each U32 CUBE word and
// zero-extends it to U32. Offset/count controls are checked before effects.
// NDF-END: PTO-TUNPACK-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TUNPACK() => TileOperation
begin
    return TileOperation_TUNPACK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TUNPACK() => TileSemanticHandler
begin
    return TileHandler_TUNPACK;
end;

pure func InstructionContractDataTypeLegal_TUNPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TUNPACK(destination, source, control);
end;

func InstructionContractExecute_TUNPACK(
    destination: TileIndex, source: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TUNPACK(destination, source, control);
    TUNPACK(destination, source, control);
end;
// DOC-END: operation
