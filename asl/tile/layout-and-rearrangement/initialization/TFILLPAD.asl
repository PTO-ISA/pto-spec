// PTO-INSTRUCTION: {"assembly":["TFILLPAD <bundle operands>"],"block":["BSTART.SFU TFILLPAD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[72],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TFILLPAD","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_TFILLPAD","mode":3,"name":"TFILLPAD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"padding"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x065","semantic_handler":"TFILLPAD","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:padding"]}],"classification":["layout-and-rearrangement","initialization"],"contract":{"block_composition":["BSTART.SFU TFILLPAD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"canonical_assembly":["TFILLPAD <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TFILLPAD schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TFILLPAD.","B.IOR.RegSrc0 supplies the padding scalar; omitted B.IOR selects zero and only the low selected-element-width bits participate."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TFILLPAD, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TFILLPAD is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TFILLPAD validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"PadValueOrByteId\",\"Layout\"],\"pad_union\":\"pad-value\"}]."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"padding"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Snapshot the source and bound scalar, copy every valid source coordinate, and write the bound scalar to every non-valid physical destination coordinate.","Mark the full physical destination defined, set contents_defined=TRUE, and publish payload, definedness, and descriptor atomically after complete preflight."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-GENERATION","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TFILLPAD","mnemonic":"TFILLPAD","summary":"Copy the source and fill destination padding elements with the bound scalar.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TFILLPAD-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TFILLPAD MUST copy the source valid rectangle and fill every other physical
// destination element with the low selected-width bits of B.IOR.RegSrc0.
// Omitted B.IOR MUST select zero. The complete physical result MUST become
// defined and publish atomically after source and scalar snapshots.
// NDF-END: PTO-TFILLPAD-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;

pure func InstructionContractDataTypeLegal_TFILLPAD(
    data_type: TileDataType) => boolean
begin
    return TileFillPadDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word) => boolean
begin
    return TileOperandsLegal_TFILLPAD(destination, source, padding);
end;

func InstructionContractExecute_TFILLPAD(
    destination: TileIndex,
    source: TileIndex,
    padding: Word)
begin
    assert InstructionContractOperandsLegal_TFILLPAD(
        destination,
        source,
        padding);
    TFILLPAD(destination, source, padding);
end;
// DOC-END: operation
