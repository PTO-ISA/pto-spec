// PTO-INSTRUCTION: {"assembly":["TDIV <bundle operands>"],"block":["BSTART.SFU TDIV, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[3],"catalog_records":[{"arguments":[{"constant":"TileBinary_DIV"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":3,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TDIV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"numerator"},{"field":"source1","role":"denominator"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x003","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:numerator","operand:source1:denominator"]}],"classification":["elementwise-tile-tile","transcendental"],"contract":{"block_composition":["BSTART.SFU TDIV, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TDIV <bundle operands>"],"defaults":["LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","The numeric profile owns fixed rounding, floating exceptional values, and floating positive or negative zero division."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TDIV, S64; B.DIM LB0=ValidCol; B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["An integer zero in the valid denominator rectangle raises Fault_TileLegality before source snapshots, allocation publication, or destination effects; denominator padding is not read.","Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile."],"field_contracts":{},"field_zero_meanings":{},"legality":["TDIV retains TEPL carrier Mode 0 Function 3 but is canonically classified as SFU.","Exactly one terminating Local B.IOT supplies ordered numerator and denominator sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.","The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","Both source valid rectangles are defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and the selected mask.","Only B.DATR PadValueOrByteId is applicable."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"ordered numerator"},{"field":"source1","role":"ordered denominator"}],"ordering":["Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write."],"standalone_opcode":false,"state_effects":["Signed integers use signed division, unsigned integers use unsigned division, and floating values use the selected floating division profile.","The valid quotient and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TDIV","mnemonic":"TDIV","summary":"Divide corresponding Local Tile elements under the selected numeric profile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TDIV-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TDIV MUST retain TEPL Mode 0 Function 3 while executing on the SFU engine.
// It MUST divide an ordered Local numerator by denominator using the selected
// arithmetic type. Integer zero in the valid denominator rectangle MUST raise
// Illegal Block Exception before effects; floating zero MUST enter the numeric
// profile. Shape defaults, PadValue, snapshots, and publication MUST follow
// the closed binary Tile contract.
// NDF-END: PTO-TDIV-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;

readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;
// DOC-END: operation
