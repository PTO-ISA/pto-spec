// PTO-INSTRUCTION: {"assembly":["TSELS <bundle operands>"],"block":["BSTART.VEC TSELS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarFalseGPR, zero, zero, ->zero (optional)","BSTOP"],"catalog_indices":[38],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelectScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelectScalar","mode":1,"name":"TSELS","operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"packed Local predicate mask"},{"field":"source1","role":"persistent Local source selected by one"},{"field":"scalar0","role":"per-participating-PE scalar selected by zero"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x03A","semantic_handler":"ExecuteTileSelectScalar","state_effects":["operand:destination0:new-local-numeric-destination","operand:source0:packed-predicate-mask","operand:source1:persistent-local-source-true","operand:scalar0:private-gpr-scalar-false","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","logical"],"contract":{"block_composition":["BSTART.VEC TSELS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarFalseGPR, zero, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TSELS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.","Omitted B.IOR supplies the selected DataType all-zero false scalar; explicit all-zero is distinct but supplies the same value. TSELS is a raw-carrier operation: predicate-one copies SrcTrue carrier bits, predicate-zero copies the scalar's low physical carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected source or scalar payloads, and performs no conversion or numeric-status update.","Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSELS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarFalseGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["Malformed binding order, B.IOS presence, surplus B.IOR fields, unsupported type, ordinary numeric mask storage, undefined predicate or true-source data, shape mismatch, capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.","Selection copies exact encodings and does not itself raise floating invalid for a selected NaN.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when present; omission selects Null.","B.IOR.RegSrc0":"Architectural zero register."},"legality":["TSELS is selected only by the TEPL raw carrier Mode 1 Function 26 and executes on VEC.","Exactly one terminating Local B.IOT supplies packed Predicate, numeric SrcTrue, and one newly allocated numeric destination. B.IOS and additional Tile bindings are illegal.","The data DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.","Predicate uses packed predicate-kind storage with matching logical geometry and every valid bit defined. SrcTrue and destination match physical shape, valid shape, row-major layout, and DataType; numeric encoding validity is not required for selected source or scalar carrier payloads.","Only RegSrc0 may be nonzero in B.IOR and only PadValueOrByteId is applicable in B.DATR.","PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"packed Local predicate mask"},{"field":"source1","role":"persistent Local source selected by one"},{"field":"scalar0","role":"per-participating-PE scalar selected by zero"}],"ordering":["Complete schema, dimensions, attributes, predicate-kind, source-definedness, scalar encoding, mask, capacity, and allocation preflight precedes snapshots.","Predicate bits, true-source payload, and scalar are snapshotted before destination publication."],"standalone_opcode":false,"state_effects":["Predicate bit one copies the exact SrcTrue element encoding and bit zero copies the normalized low-width scalar encoding.","Selection performs no rounding, saturation, canonicalization, or numeric-status update.","Selected payload, padding definedness, and destination descriptor publish atomically; rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSELS","mnemonic":"TSELS","summary":"Select each result encoding from a Local Tile or private-GPR scalar under one packed predicate Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSELS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSELS MUST read one packed predicate, one Local true source, and one
// private-GPR false scalar. Predicate bit one MUST copy the source encoding;
// bit zero MUST copy the scalar encoding. Complete preflight and all snapshots
// MUST precede atomic payload, padding, and descriptor publication.
// NDF-END: PTO-TSELS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSELS(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;

readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;

func InstructionContractExecute_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word)
begin
    assert InstructionContractOperandsLegal_TSELS(
        destination,
        predicate,
        source_true,
        scalar_false);
    ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;
// DOC-END: operation
