// PTO-INSTRUCTION: {"assembly":["TREM <bundle operands>"],"block":["BSTART.SFU TREM, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[4],"catalog_records":[{"arguments":[{"constant":"TileBinary_REM"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TREM","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"dividend"},{"field":"source1","role":"divisor"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x004","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:dividend","operand:source1:divisor"]}],"classification":["elementwise-tile-tile","transcendental"],"contract":{"block_composition":["BSTART.SFU TREM, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TREM <bundle operands>"],"defaults":["LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","The numeric profile owns fixed rounding, signed overflow boundaries, floating exceptional values, and floating zero modulo."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TREM, S64; B.DIM LB0=ValidCol; B.IOT Dividend, Divisor, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["An integer zero in the valid divisor rectangle raises Fault_TileLegality before snapshots, allocation publication, or destination effects; divisor padding is not read.","Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile."],"field_contracts":{},"field_zero_meanings":{},"legality":["TREM retains TEPL carrier Mode 0 Function 4 but is canonically classified as SFU.","Exactly one terminating Local B.IOT supplies ordered dividend and divisor sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.","DataType is exactly S32, U32, FP32, S16, U16, FP16, or BF16.","Only B.DATR PadValueOrByteId is applicable.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"ordered dividend"},{"field":"source1","role":"ordered divisor"}],"ordering":["Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write."],"standalone_opcode":false,"state_effects":["Signed integer modulo uses floor division so a nonzero result has the divisor's sign; unsigned integers use ordinary unsigned remainder and floating values use the selected modulo profile.","The valid modulo result and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TREM","mnemonic":"TREM","summary":"Compute divisor-signed modulo for corresponding Local Tile elements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TREM-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TREM MUST retain TEPL Mode 0 Function 4 while executing on the SFU engine.
// Signed integer and floating modulo MUST use floor division so a nonzero
// result has the divisor sign; unsigned integer modulo MUST use unsigned
// remainder. Integer zero in the valid divisor rectangle MUST reject before
// effects. Shape defaults, PadValue, snapshots, and atomic publication MUST
// follow the closed binary Tile contract.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TREM-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TREM() => TileOperation
begin
    return TileOperation_TREM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TREM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;

readonly func InstructionContractHandler_TREM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TREM(
    destination: TileIndex,
    dividend: TileIndex,
    divisor: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_REM,
        destination,
        dividend,
        divisor);
end;
// DOC-END: operation
