// PTO-INSTRUCTION: {"assembly":["TUNPACK <bundle operands>"],"block":["BSTART.SFU TUNPACK, U8/U16/U32","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source, ->destination","B.IOR unpack_control","BSTOP"],"catalog_indices":[97],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TUNPACK","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":24,"legality_handler":"TileOperandsLegal_TUNPACK","mode":3,"name":"TUNPACK","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"unpack-control"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x078","semantic_handler":"TUNPACK","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:unpack-control"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TUNPACK, U8/U16/U32","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source, ->destination","B.IOR unpack_control","BSTOP"],"canonical_assembly":["TUNPACK <bundle operands>"],"defaults":["A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TUNPACK, U8/U16/U32; B.DATR Layout; B.DIM LB0; B.IOT source, ->destination; B.IOR a0; BSTOP"],"exceptions":["Unsupported storage, layout, or backing width; a selected interval outside a source word logical valid-byte span; an undefined selected byte; or illegal offset/count fields reject with Fault_TileLegality before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TUNPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit elements.","BSTART selects exactly U8, U16, or U32 for the fresh destination. The control selects a contiguous byte field within each independent 32-bit source word.","Only selected source bytes are read. Every selected interval is inside its word logical valid-byte span and every selected byte has a defined containing element; each participating word produces one complete zero-filled destination word."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"unpack-control"}],"ordering":["Control and source validation precede destination publication."],"standalone_opcode":false,"state_effects":["Extract the selected byte field independently from each participating 32-bit raw-word slot, zero-fill the remainder, and publish one complete destination word per source word."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TUNPACK","mnemonic":"TUNPACK","summary":"Extract selected byte fields from 8/16/32-bit Local CUBE source carriers into U8/U16/U32 destination words.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TUNPACK-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TUNPACK reads unchanged Local Numeric CUBE_M16 or CUBE_M32 source backing carriers with non-packed 8, 16, or 32-bit elements. BSTART selects exactly U8, U16, or U32 for the destination operation type; source backing type need not equal it.
// The control selects one contiguous byte field within each independent 32-bit source word. A partial final source word participates when the selected interval lies within its logical valid-byte span. Only selected bytes are read, and each selected byte's containing element MUST be defined; unselected valid bytes and physical padding are not read.
// Each participating source word produces one complete valid destination word with selected bytes in its low bytes and zero in every remaining byte. Destination columns are derived from raw-word count and BSTART element width. Validation precedes snapshot and atomic publication; TUNPACK performs no numeric conversion or status update.
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
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32;
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
