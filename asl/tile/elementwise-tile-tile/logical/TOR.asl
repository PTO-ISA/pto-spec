// PTO-INSTRUCTION: {"assembly":["TOR <bundle operands>"],"block":["BSTART.VEC TOR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[6],"catalog_records":[{"arguments":[{"constant":"TileBinary_OR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TOR","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x007","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TOR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TOR <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TOR, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched sources, a non-row-major layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.","Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal before source snapshots or destination allocation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TOR is selected by TEPL carrier Mode 0 Function 7 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination; B.IOR and B.IOS are not accepted.","DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.","Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.","PadValueOrByteId is the only applicable B.DATR field; PE_MASK=0000 is a strict no-op before reads, allocation, or faults."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"ordered left Local source"},{"field":"source1","role":"ordered right Local source"}],"ordering":["Both source payloads are snapshotted after complete preflight and before the first destination write."],"standalone_opcode":false,"state_effects":["Apply element-width bitwise OR to corresponding valid source elements; signedness does not change the bit operation and carrier bits above the selected width are zero.","Either source may alias the destination with read-old/write-new behavior, and both sources may name the same Tile.","Publish the complete valid result and selected physical padding definedness as one destination commit; rejection leaves descriptors, payloads, and allocation state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TOR","mnemonic":"TOR","summary":"Compute the bitwise OR of corresponding integer elements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TOR-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TOR MUST select VEC Mode 0 Function 7 and MUST compute the bitwise OR of
// corresponding integer elements. It MUST accept only S64/S32/S16/S8 and
// U64/U32/U16/U8. PadValue, shape defaults, source snapshots, and atomic
// destination publication MUST follow the closed Local binary Tile contract.
// NDF-END: PTO-TOR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TOR() => TileOperation
begin
    return TileOperation_TOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TOR(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(TileBinary_OR, data_type);
end;

readonly func InstructionContractOperandsLegal_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_OR,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
