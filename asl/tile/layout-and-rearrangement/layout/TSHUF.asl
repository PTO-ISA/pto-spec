// PTO-INSTRUCTION: {"assembly":["TSHUF <bundle operands>"],"block":["BSTART.SFU TSHUF, DataType","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source, controls, ->destination","B.IOR shuffle_control","BSTOP"],"catalog_indices":[95],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSHUF","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":22,"legality_handler":"TileOperandsLegal_TSHUF","mode":3,"name":"TSHUF","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"controls"},{"field":"scalar0","role":"shuffle-control"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x076","semantic_handler":"TSHUF","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:controls","operand:scalar0:shuffle-control"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TSHUF, DataType","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source, controls, ->destination","B.IOR shuffle_control","BSTOP"],"canonical_assembly":["TSHUF <bundle operands>"],"defaults":["A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TSHUF, U32; B.DATR Layout; B.IOT source, controls, ->destination; B.IOR a0; BSTOP"],"exceptions":["Reserved control encodings reject with Fault_TileLegality before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TSHUF accepts Local CUBE_M16 or CUBE_M32 data and U32 control Tiles with matching geometry.","The control word selects UP, DOWN, BFLY, or IDX; segment and boundary fields are checked before execution.","Raw 32-bit words are shuffled without byte permutation."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"controls"},{"field":"scalar0","role":"shuffle-control"}],"ordering":["Source and control snapshots precede destination publication."],"standalone_opcode":false,"state_effects":["Perform independent PTX-style word shuffles for each active CUBE row/group."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TSHUF","mnemonic":"TSHUF","summary":"Shuffle raw 32-bit words across Local CUBE rows with an explicit control GPR.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSHUF-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSHUF selects raw 32-bit words inside independent power-of-two row segments.
// Control mode, segment, and boundary fields are checked before publication;
// SELF and ZERO define out-of-segment behavior without predicates.
// NDF-END: PTO-TSHUF-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSHUF() => TileOperation
begin
    return TileOperation_TSHUF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSHUF() => TileSemanticHandler
begin
    return TileHandler_TSHUF;
end;

pure func InstructionContractDataTypeLegal_TSHUF(
    data_type: TileDataType) => boolean
begin
    return TileCubeDataTypeSupported(data_type) &&
           TileElementBits(data_type) != 64;
end;

readonly func InstructionContractOperandsLegal_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word) => boolean
begin
    return TileOperandsLegal_TSHUF(destination, source, controls, control);
end;

func InstructionContractExecute_TSHUF(
    destination: TileIndex, source: TileIndex,
    controls: TileIndex, control: Word)
begin
    assert InstructionContractOperandsLegal_TSHUF(
        destination, source, controls, control);
    TSHUF(destination, source, controls, control);
end;
// DOC-END: operation
