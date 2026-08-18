// PTO-INSTRUCTION: {"assembly":["TXOR <bundle operands>"],"block":["BSTART.VEC TXOR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[7],"catalog_records":[{"arguments":[{"constant":"TileBinary_XOR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TXOR","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x008","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TXOR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TXOR <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TXOR, U8; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched sources, a non-row-major layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.","Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal before source snapshots or destination allocation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TXOR is selected by TEPL carrier Mode 0 Function 8 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local sources and one newly allocated Local destination; B.IOR and B.IOS are not accepted.","DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.","Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.","PadValueOrByteId is the only applicable B.DATR field; PE_MASK=0000 is a strict no-op before reads, allocation, or faults."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"ordered left Local source"},{"field":"source1","role":"ordered right Local source"}],"ordering":["Both source payloads are snapshotted after complete preflight and before the first destination write."],"standalone_opcode":false,"state_effects":["Apply element-width bitwise XOR to corresponding valid source elements; signedness does not change the bit operation and carrier bits above the selected width are zero.","Either source may alias the destination with read-old/write-new behavior, and both sources may name the same Tile.","Publish the complete valid result and selected physical padding definedness as one destination commit; rejection leaves descriptors, payloads, and allocation state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TXOR","mnemonic":"TXOR","summary":"Compute the bitwise XOR of corresponding integer elements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TXOR-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TXOR MUST select VEC Mode 0 Function 8 and MUST compute the bitwise XOR of
// corresponding integer elements. It MUST accept only S64/S32/S16/S8 and
// U64/U32/U16/U8. PadValue, shape defaults, source snapshots, and atomic
// destination publication MUST follow the closed Local binary Tile contract.
// NDF-END: PTO-TXOR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TXOR() => TileOperation
begin
    return TileOperation_TXOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TXOR(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOnlyDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TXOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_XOR,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TXOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TXOR(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_XOR,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
