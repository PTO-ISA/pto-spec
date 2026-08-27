// PTO-INSTRUCTION: {"assembly":["TTRI <bundle operands>"],"block":["BSTART.SFU TTRI, FP32|FP16|S32|S16|U32|U16","B.DATR all-zero (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR Diagonal, Orientation (optional; omission selects 0 and lower)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[73],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"flag0"},{"operand":"diagonal"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TTRI","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_TTRI","mode":3,"name":"TTRI","operands":[{"field":"destination0","role":"new Local triangular destination"},{"field":"flag0","role":"lower or upper orientation"},{"field":"diagonal","role":"signed diagonal displacement"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x067","semantic_handler":"TTRI","state_effects":["operand:destination0:new-local-triangular-destination","operand:flag0:lower-or-upper-orientation","operand:diagonal:signed-diagonal-displacement","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","initialization"],"contract":{"block_composition":["BSTART.SFU TTRI, FP32|FP16|S32|S16|U32|U16","B.DATR all-zero (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR Diagonal, Orientation (optional; omission selects 0 and lower)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TTRI <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one. Omitted LB2 selects Col equal to ValidCol.","Omitted B.IOR selects diagonal zero and lower orientation. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.","Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TTRI, FP16; B.DIM LB0=16; B.DIM LB1=8; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<2>; BSTOP"],"exceptions":["Malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, orientation other than zero or one, diagonal outside -65535 through 65535, or a nonzero inapplicable B.DATR field raises Fault_TileLegality before allocation.","An unrepresentable shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.","PE_MASK zero completes as a strict no-op before every validation or effect."],"field_contracts":{"B.IOR.RegDst":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc2":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR":"Omission selects diagonal zero and lower orientation; encoded zero selectors explicitly read GPR0 and produce the same operand values.","B.DATR":"All fields zero; every nonzero field is inapplicable.","B.DIM.LB1":"Omission selects one valid row.","B.DIM.LB2":"Omission selects physical Col equal to ValidCol."},"legality":["TTRI is selected by the TEPL encoding carrier Mode 3 Function 7, canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.","The selected DataType is exactly FP32, FP16, S32, S16, U32, or U16. The destination is row-major with nonzero ValidRow and ValidCol, and Col is at least ValidCol.","A present B.IOR consumes RegSrc0 as signed diagonal and RegSrc1 as exact zero or one orientation. RegSrc2 and RegDst are zero.","Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local triangular destination"},{"field":"flag0","role":"lower or upper orientation"},{"field":"diagonal","role":"signed diagonal displacement"}],"ordering":["Complete schema, type, dimensions, TSize, diagonal, orientation, mask, destination-name, and allocation preflight precedes generation.","The triangular payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For lower orientation, logical element [r,c] is typed one exactly when c is at most r plus diagonal; otherwise it is typed zero.","For upper orientation, logical element [r,c] is typed one exactly when c is at least r plus diagonal; otherwise it is typed zero.","Signed boundary comparison does not wrap. FP32 and FP16 use their exact positive-zero and positive-one encodings. Every physical coordinate outside the valid rectangle is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"],"engine":"SFU","id":"PTO-TILE-TTRI","mnemonic":"TTRI","summary":"Generate an exact typed lower or upper triangular matrix in a new Local Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TTRI-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TTRI MUST select SFU Mode 3 Function 7. It MUST publish one newly allocated
// row-major Local FP32, FP16, S32, S16, U32, or U16 destination. Lower
// orientation MUST write typed one when c <= r+diagonal; upper orientation
// MUST write typed one when c >= r+diagonal. Every other valid element MUST
// be typed zero, and the signed boundary comparison MUST NOT wrap.
// NDF-END: PTO-TTRI-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TTRI() => TileOperation
begin
    return TileOperation_TTRI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TTRI(
    data_type: TileDataType) => boolean
begin
    return TileTTRIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultDiagonal_TTRI()
    => integer {-65535..65535}
begin
    return 0;
end;

pure func InstructionContractDefaultUpper_TTRI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TTRI(
    destination: TileIndex,
    upper: boolean,
    diagonal: integer {-65535..65535}) => boolean
begin
    return TileOperandsLegal_TTRI(
        destination,
        upper,
        diagonal);
end;

readonly func InstructionContractHandler_TTRI() => TileSemanticHandler
begin
    return TileHandler_TTRI;
end;

func InstructionContractExecute_TTRI(
    destination: TileIndex,
    upper: boolean,
    diagonal: integer {-65535..65535})
begin
    assert InstructionContractOperandsLegal_TTRI(
        destination,
        upper,
        diagonal);
    TTRI(
        destination,
        upper,
        diagonal);
end;
// DOC-END: operation
