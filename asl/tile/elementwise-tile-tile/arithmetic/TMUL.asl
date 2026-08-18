// PTO-INSTRUCTION: {"assembly":["TMUL <bundle operands>"],"block":["BSTART.VEC TMUL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[2],"catalog_records":[{"arguments":[{"constant":"TileBinary_MUL"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TMUL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x002","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","arithmetic"],"contract":{"block_composition":["BSTART.VEC TMUL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TMUL <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TMUL, U64; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["TMUL is BSTART.VEC Mode 0 Function 2 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.","DataType is one of S32, U32, FP32, S16, U16, FP16, or BF16.","Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.","Only B.DATR PadValueOrByteId is applicable."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"left factor"},{"field":"source1","role":"right factor"}],"ordering":["Both sources are snapshotted before destination writes."],"standalone_opcode":false,"state_effects":["Publish the elementwise products after complete preflight.","Pad the remaining physical region using the selected PadValue; Null padding is undefined."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TMUL","mnemonic":"TMUL","summary":"Multiply corresponding elements of two Local Tiles.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMUL-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMUL MUST select VEC Mode 0 Function 2 and MUST multiply corresponding
// elements of two ordered Local sources. The closed binary Tile schema,
// shape defaults, arithmetic DataType set, PadValue behavior, complete
// preflight, source snapshot, and atomic destination publication MUST match
// the TADD family contract. Rejection MUST precede all effects.
// NDF-END: PTO-TMUL-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMUL() => TileOperation
begin
    return TileOperation_TMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TMUL(
    data_type: TileDataType) => boolean
begin
    return TileA7DataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMUL(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MUL,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
