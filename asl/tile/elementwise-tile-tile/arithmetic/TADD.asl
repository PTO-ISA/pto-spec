// PTO-INSTRUCTION: {"assembly":["TADD <bundle operands>"],"block":["BSTART.VEC TADD, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[0],"catalog_records":[{"arguments":[{"constant":"TileBinary_ADD"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TADD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x000","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","arithmetic"],"contract":{"block_composition":["BSTART.VEC TADD, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TADD <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol; an explicitly present zero dimension is illegal.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null respectively.","The destination physical Rows are derived from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TADD, U64; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A missing LB0, malformed Local B.IOT, B.IOR or B.IOS presence, source shape or carrier-width mismatch, undefined source element, unsupported DataType, or invalid destination capacity raises Fault_TileLegality before destination effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TADD is selected only by BSTART.VEC Mode 0 Function 0 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination. B.IOR and B.IOS are not accepted; all participating Tiles use one PE_MASK and zero mask is a strict no-op.","The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","B.DATR applicability allows only PadValueOrByteId as PadValue.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"ordered left Local source"},{"field":"source1","role":"ordered right Local source"}],"ordering":["Both source payloads are snapshotted before the first destination write, so source/destination aliasing is read-before-write."],"standalone_opcode":false,"state_effects":["After complete preflight, add corresponding source elements and atomically publish the valid destination region.","Physical destination elements outside ValidRow x ValidCol receive the selected PadValue; Null padding remains undefined while Zero, Max, and Min padding are defined."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TADD","mnemonic":"TADD","summary":"Add corresponding elements of two Local Tiles.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TADD-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TADD MUST select VEC Mode 0 Function 0 and MUST consume exactly two
// ordered Local Tile sources plus one newly allocated Local Tile destination.
// LB0 MUST provide nonzero ValidCol; omitted LB1 MUST select ValidRow=1;
// omitted LB2 MUST select Col=ValidCol. Omitted B.DATR MUST select Null
// padding; explicit PadValue 00, 01, 10, and 11 MUST select Zero, Max, Min,
// and Null respectively. Both sources MUST be completely defined and match
// the destination shape, row-major layout, and one supported arithmetic type.
// Complete legality and allocation preflight MUST precede source snapshots;
// the valid result and padding MUST publish together after elementwise add.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TADD-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TADD() => TileOperation
begin
    return TileOperation_TADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_ADD,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
