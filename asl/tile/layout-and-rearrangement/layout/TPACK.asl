// PTO-INSTRUCTION: {"assembly":["TPACK <bundle operands>"],"block":["BSTART.SFU TPACK, U8/U16/U32","B.DATR Layout (optional)","B.DIM LB0 (optional)","B.IOT source0, source1, ->destination","B.IOR pack_control","BSTOP"],"catalog_indices":[96],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TPACK","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":23,"legality_handler":"TileOperandsLegal_TPACK","mode":3,"name":"TPACK","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"scalar0","role":"pack-control"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x077","semantic_handler":"TPACK","state_effects":["operand:destination0:destination","operand:source0:source0","operand:source1:source1","operand:scalar0:pack-control"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TPACK, U8/U16/U32","B.DATR Layout (optional)","B.DIM LB0/LB1/LB2 (optional)","B.IOT source0, source1, ->destination","B.IOR pack_control","BSTOP"],"canonical_assembly":["TPACK <bundle operands>"],"defaults":["A nonzero PE mask requires exactly one B.IOR control input; RegSrc1, RegSrc2, and RegDst are zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TPACK, U8/U16/U32; B.DATR Layout; B.IOT source0, source1, ->destination; B.IOR a0; BSTOP"],"exceptions":["Unsupported storage, layout, or backing width; unequal raw-word counts; an out-of-span or undefined selected byte; or illegal field widths reject with Fault_TileLegality before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior."],"field_contracts":{},"field_zero_meanings":{},"legality":["TPACK accepts Local Numeric CUBE_M16 or CUBE_M32 source backing with non-packed 8/16/32-bit elements; source layouts and valid rows match and RawWordSlotsPerRow is equal.","BSTART selects exactly U8, U16, or U32 for the fresh destination. The control selects low-byte prefixes of 1..3 bytes per source word with total width at most four.","Only selected source bytes are read. Each selected byte is logically valid and its containing element is defined; each paired 32-bit word produces one complete zero-filled destination word."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"scalar0","role":"pack-control"}],"ordering":["Control and source validation precede destination publication."],"standalone_opcode":false,"state_effects":["Pair corresponding 32-bit raw-word slots independently in each row, assemble the selected low-byte prefixes, and zero every unselected destination byte."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TPACK","mnemonic":"TPACK","summary":"Pack selected raw byte prefixes from 8/16/32-bit Local CUBE source carriers into U8/U16/U32 destination words.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TPACK-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TPACK treats each source as an unchanged Local Numeric CUBE_M16 or CUBE_M32 backing carrier with a non-packed 8, 16, or 32-bit element width. BSTART selects exactly U8, U16, or U32 for the destination operation type; each source raw-word slot is paired independently, and the two sources MUST have equal raw-word counts per row.
// The control selects low-byte prefixes of 1..3 bytes from each paired 32-bit word, with total width at most four. Only selected bytes are read; each selected byte MUST be within that source word's logical valid-byte span and its containing element MUST be defined. Unselected bytes, including physical padding, are not read.
// Each paired source word produces one complete valid destination word with selected bytes in order and all remaining bytes zero. Destination columns are derived from raw-word count and BSTART element width. Validation precedes snapshot and atomic publication; TPACK performs no numeric conversion or status update.
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
    return data_type == TileDataType_U8 ||
           data_type == TileDataType_U16 ||
           data_type == TileDataType_U32;
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
