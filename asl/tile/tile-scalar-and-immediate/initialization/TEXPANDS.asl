// PTO-INSTRUCTION: {"assembly":["TEXPANDS <bundle operands>"],"block":["BSTART.VEC TEXPANDS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"catalog_indices":[39],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileFillScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"TileOperandsLegal_ExecuteTileFillScalar","mode":1,"name":"TEXPANDS","operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x03B","semantic_handler":"ExecuteTileFillScalar","state_effects":["operand:destination0:new-local-numeric-destination","operand:scalar0:private-gpr-raw-element","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","initialization"],"contract":{"block_composition":["BSTART.VEC TEXPANDS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TEXPANDS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.","Omitted B.IOR supplies the selected DataType all-zero encoding; explicit all-zero is distinct but supplies the same value.","Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TEXPANDS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["Malformed destination binding, B.IOS presence, surplus B.IOR fields, unsupported DataType, missing or zero dimensions, capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when present; omission selects Null.","B.IOR.RegSrc0":"Architectural zero register."},"legality":["TEXPANDS is selected only by the TEPL raw carrier Mode 1 Function 27 and executes on VEC.","Exactly one terminating Local B.IOT supplies no source and one newly allocated Local numeric destination. B.IOS and additional Tile bindings are illegal.","The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other type rejects before effects.","The destination uses selected RowMajor, CUBE_M16, or CUBE_M32 layout; CUBE_M16 valid_rows is at most 16 and CUBE_M32 valid_rows is at most 32, with physical geometry derived from the selected layout and capacity.","Only RegSrc0 may be nonzero in B.IOR and only PadValueOrByteId is applicable in B.DATR.","PE_MASK=0000 is a strict no-op before GPR reads, allocation, faults, or destination effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"ordering":["Complete schema, dimensions, attributes, type, scalar encoding, mask, capacity, and allocation preflight precedes the private-GPR scalar snapshot."],"standalone_opcode":false,"state_effects":["Every valid destination element receives the scalar low element-width raw encoding without conversion.","Padding definedness and destination descriptor publish atomically; rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TEXPANDS","mnemonic":"TEXPANDS","summary":"Broadcast one private-GPR scalar encoding across a newly allocated Local Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TEXPANDS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TEXPANDS MUST read one optional B.IOR.RegSrc0 private-GPR scalar, MUST use
// no Tile source, and MUST fill the valid region of one renamed Local numeric
// destination with the scalar low-width encoding. Complete legality and
// allocation preflight MUST precede atomic value, padding, and descriptor
// publication.
// Layout 29 selects direct Local CUBE_M32 and Layout 31 selects direct Local CUBE_M16. Omitted B.DATR and Layout=NORM retain RowMajor; all Tile operands in one operation MUST use the same layout.
// NDF-END: PTO-TEXPANDS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXPANDS() => TileOperation
begin
    return TileOperation_TEXPANDS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TEXPANDS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXPANDS(
    destination: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileFillScalar(
        destination,
        scalar);
end;

readonly func InstructionContractHandler_TEXPANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileFillScalar;
end;

func InstructionContractExecute_TEXPANDS(
    destination: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TEXPANDS(
        destination,
        scalar);
    ExecuteTileFillScalar(
        destination,
        scalar);
end;
// DOC-END: operation
