// PTO-INSTRUCTION: {"assembly":["TPACK <bundle operands>"],"block":["BSTART.SFU TPACK, U32","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source0, source1, ->destination","B.IOR pack_control","BSTOP"],"catalog_indices":[96],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TPACK","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":23,"legality_handler":"TileOperandsLegal_TPACK","mode":3,"name":"TPACK","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"scalar0","role":"pack-control"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x077","semantic_handler":"TPACK","state_effects":["operand:destination0:destination","operand:source0:source0","operand:source1:source1","operand:scalar0:pack-control"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TPACK, U32","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source0, source1, ->destination","B.IOR pack_control","BSTOP"],"canonical_assembly":["TPACK <bundle operands>"],"defaults":["A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TPACK, U32; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP"],"exceptions":["Illegal field widths reject with Fault_TileLegality before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TPACK accepts only Local U32 CUBE_M16 or CUBE_M32 sources and a fresh matching destination.","The control selects two low-order byte fields with widths 1..3 whose sum is at most four.","The result is raw zero-filled field assembly with no numeric conversion."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"scalar0","role":"pack-control"}],"ordering":["Control and source validation precede destination publication."],"standalone_opcode":false,"state_effects":["Pack corresponding source U32 words independently in every active CUBE word group."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TPACK","mnemonic":"TPACK","summary":"Pack two low-order raw byte fields into Local U32 CUBE words.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TPACK-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TPACK assembles two low-order byte fields into each corresponding U32 word.
// Widths are explicit control bytes in 1..3 with total width at most four;
// all unselected result bits are zero.
// NDF-END: PTO-TPACK-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPACK() => TileOperation
begin
    return TileOperation_TPACK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPACK() => TileSemanticHandler
begin
    return TileHandler_TPACK;
end;

pure func InstructionContractDataTypeLegal_TPACK(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U32;
end;

readonly func InstructionContractOperandsLegal_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TPACK(destination, source0, source1, control);
end;

func InstructionContractExecute_TPACK(
    destination: TileIndex, source0: TileIndex,
    source1: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TPACK(
        destination, source0, source1, control);
    TPACK(destination, source0, source1, control);
end;
// DOC-END: operation
