// PTO-INSTRUCTION: {"assembly":["TRECIP <bundle operands>"],"block":["BSTART.SFU TRECIP, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[18],"catalog_records":[{"arguments":[{"constant":"TileUnary_RECIP"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileUnary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":20,"legality_handler":"TileOperandsLegal_ExecuteTileUnary","mode":0,"name":"TRECIP","operands":[{"field":"destination0","role":"new Local floating destination"},{"field":"source0","role":"persistent Local floating source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x014","semantic_handler":"ExecuteTileUnary","state_effects":["operand:destination0:new-local-floating-destination","operand:source0:persistent-local-floating-source","runtime:CurrentBundlePadValue:numeric-padding","runtime:NumericStatusFlags:profile-status"]}],"classification":["elementwise-tile-tile","transcendental"],"contract":{"block_composition":["BSTART.SFU TRECIP, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TRECIP <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","The selected numeric profile supplies the operation-fixed approximation, rounding, exceptional result, and exact NV/DZ/OF/UF/NX status vector."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TRECIP, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed Local bindings, B.IOR or B.IOS presence, missing or zero dimensions, unsupported DataType, undefined or invalid source encoding, descriptor mismatch, invalid capacity, or allocation failure raises the applicable Tile fault before effects.","Floating zero is legal, reports divide-by-zero, and produces signed infinity where representable; signed infinity produces signed zero; signaling NaN records invalid and every NaN produces a quiet-NaN result.","E4M3 has no infinity encoding and TRECIP does not admit saturation, so either signed zero produces canonical E4M3 quiet NaN 0x7F and records only divide-by-zero without overflow."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null."},"legality":["TRECIP retains its TEPL raw Mode 0 carrier and executes canonically on the SFU engine.","Exactly one terminating Local B.IOT supplies one persistent source and one newly allocated destination. B.IOR and B.IOS are illegal.","The selected DataType is exactly FP16, FP32, or BF16; every integer, exponent-only, other compact, packed, assigned-but-inapplicable, or reserved DataType rejects before effects.","PadValueOrByteId is the only applicable B.DATR field; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, numeric status, or payload effects.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local floating destination"},{"field":"source0","role":"persistent Local floating source"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, and allocation preflight precedes the source snapshot and profile evaluation.","The complete source payload is snapshotted before destination publication, so source/destination aliasing observes the old source value."],"standalone_opcode":false,"state_effects":["For each valid element compute the selected profile's same-type reciprocal.","Accumulate all element status flags, apply selected physical padding, and publish payload, definedness, numeric status, and destination descriptor atomically; rejection leaves architectural state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TRECIP","mnemonic":"TRECIP","summary":"Compute the same-type reciprocal of every valid Local Tile element.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TRECIP-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TRECIP MUST compute one same-type reciprocal for every valid Local
// floating element. Either E4M3 signed zero MUST produce canonical quiet
// NaN 0x7F and MUST set DZ without setting OF.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TRECIP-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TRECIP() => TileOperation
begin
    return TileOperation_TRECIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TRECIP(
    data_type: TileDataType) => boolean
begin
    return TileUnaryDataTypeSupported(
        TileUnary_RECIP,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TRECIP(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;

readonly func InstructionContractHandler_TRECIP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TRECIP(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TRECIP(
        destination,
        source);
    ExecuteTileUnary(
        TileUnary_RECIP,
        destination,
        source);
end;
// DOC-END: operation
