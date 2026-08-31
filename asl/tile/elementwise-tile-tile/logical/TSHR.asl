// PTO-INSTRUCTION: {"assembly":["TSHR <bundle operands>"],"block":["BSTART.VEC TSHR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[9],"catalog_records":[{"arguments":[{"constant":"TileBinary_SHR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":10,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TSHR","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"value-source"},{"field":"source1","role":"shift-count-source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00A","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:value-source","operand:source1:shift-count-source"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TSHR, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TSHR <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Physical Rows derive from TSize, Col, and DataType; Rows and Col are powers of two and contain ValidRow x ValidCol."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSHR, U8; B.DIM LB0=ValidCol; B.IOT Value, ShiftCount, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched sources, a non-row-major layout, an unsupported DataType, or invalid destination capacity raises Fault_TileLegality before effects.","Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal before source snapshots or destination allocation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TSHR is selected by TEPL carrier Mode 0 Function 10 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies ordered value and shift-count sources plus one newly allocated Local destination; B.IOR and B.IOS are not accepted.","DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; packed and floating formats reject before effects.","PadValueOrByteId is the only applicable B.DATR field; PE_MASK=0000 is a strict no-op before reads, allocation, or faults.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"integer value source"},{"field":"source1","role":"integer shift-count source"}],"ordering":["Both source payloads are snapshotted after complete preflight and before the first destination write."],"standalone_opcode":false,"state_effects":["For element width W, use the unsigned low log2(W) bits of source1 as the count; signed source0 shifts arithmetically, unsigned source0 shifts logically, and carrier bits above W are zero.","Either source may alias the destination with read-old/write-new behavior, and both sources may name the same Tile.","Publish the complete valid result and selected physical padding definedness as one destination commit; rejection leaves descriptors, payloads, and allocation state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSHR","mnemonic":"TSHR","summary":"Shift corresponding signed or unsigned integer elements right by masked counts.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSHR-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSHR MUST select VEC Mode 0 Function 10. For element width W, it MUST use
// the unsigned low log2(W) bits of source1 as the shift count. Signed types
// MUST shift source0 arithmetically and unsigned types MUST shift logically;
// carrier bits above W MUST be zero. Only the eight scalar integer Tile types
// are legal. Preflight and publication MUST follow the closed binary contract.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TSHR-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSHR() => TileOperation
begin
    return TileOperation_TSHR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSHR(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(TileBinary_SHR, data_type);
end;

readonly func InstructionContractOperandsLegal_TSHR(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_SHR,
        destination,
        value_source,
        count_source);
end;

readonly func InstructionContractHandler_TSHR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TSHR(
    destination: TileIndex,
    value_source: TileIndex,
    count_source: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_SHR,
        destination,
        value_source,
        count_source);
end;
// DOC-END: operation
