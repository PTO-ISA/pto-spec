// PTO-INSTRUCTION: {"assembly":["TIMG2COL <bundle operands>"],"block":["BSTART.SFU TIMG2COL, DataType","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR PosMGPR, PosKGPR, zero, ->zero (optional)","BSTOP"],"catalog_indices":[71],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TIMG2COL","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_TIMG2COL","mode":3,"name":"TIMG2COL","operands":[{"field":"destination0","role":"new Local Matrix destination"},{"field":"source0","role":"persistent Local Matrix feature-map source"},{"field":"natural0","role":"unsigned low-sixteen-bit posM"},{"field":"natural1","role":"unsigned low-sixteen-bit posK"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x064","semantic_handler":"TIMG2COL","state_effects":["operand:destination0:new-local-matrix-destination","operand:source0:persistent-feature-map-source","operand:natural0:position-m","operand:natural1:position-k","state:source-feature-map-descriptor:read-only"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TIMG2COL, DataType","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR PosMGPR, PosKGPR, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TIMG2COL <bundle operands>"],"defaults":["LB0 is required and supplies nonzero destination ValidCol. Omitted LB1 selects ValidRow=1 and omitted LB2 selects physical Col=ValidCol.","Omitted B.IOR selects posM=0 and posK=0. When present, RegSrc0 and RegSrc1 contribute their unsigned low sixteen bits; RegSrc2 and RegDst must be zero.","The source feature-map descriptor supplies layout, dimensions, filter, stride, dilation, four-sided padding, logical channel count, and the typed padding value."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TIMG2COL, FP16; B.DIM LB0=KWindow; B.DIM LB1=MWindow; B.IOT Src, mask=PE_MASK, <last>, ->Dst<TSize>; B.IOR PosM, PosK, zero, ->zero; BSTOP"],"exceptions":["An absent or invalid feature-map descriptor, transposed request, unsupported DataType, malformed binding, invalid B.DATR contribution, out-of-range matrix window, undefined referenced source element, invalid numeric encoding, or insufficient destination capacity raises the applicable Tile fault before effects.","PE_MASK=0000 is a strict no-op before descriptor or GPR reads, allocation, faults, or payload effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register, selecting posM=0.","B.IOR.RegSrc1":"The architectural zero register, selecting posK=0."},"legality":["TIMG2COL retains TEPL raw Mode 3 Function 4 and canonicalizes to the SFU engine without changing the carrier encoding.","Exactly one terminating Local B.IOT supplies one persistent Matrix-location source and one newly allocated Matrix-location destination; B.IOS is illegal.","The source descriptor layout is NC1HWC0 or NDC1HWC0; every dimension, filter, stride, and dilation is nonzero, padding is nonnegative, logical channels do not exceed C1*C0, and transposed mode is illegal.","Source and destination use the same one of FP32, FP16, BF16, S32, S16, S8, U32, U16, or U8, row-major layout, and PE_MASK.","B.DATR contributes no field. B.IOR is optional and only RegSrc0 and RegSrc1 may be nonzero.","The complete destination window at posM,posK fits N*D*outH*outW by C1*filterH*filterW*C0, and every actually referenced in-range source element is defined and validly encoded."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local Matrix destination"},{"field":"source0","role":"persistent Local Matrix feature-map source"},{"field":"natural0","role":"unsigned low-sixteen-bit posM"},{"field":"natural1","role":"unsigned low-sixteen-bit posK"}],"ordering":["Complete schema, descriptor, range, type, capacity, referenced-definedness, and allocation preflight precedes source snapshot.","The source payload and feature-map descriptor are read-only; complete destination payload and definedness publish atomically."],"standalone_opcode":false,"state_effects":["For each destination row and column, add posM and posK, decompose the logical matrix coordinates, and copy the matching NC1HWC0 or NDC1HWC0 source element.","Out-of-range spatial coordinates and packed channels beyond logical_channels receive the descriptor typed padding value.","Publish the complete standard Left matrix result without modifying the source or its feature-map descriptor."]},"depends_on":["PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN","PTO-TILE-MODEL-EXECUTION-IMAGE-TO-COLUMN"],"engine":"SFU","id":"PTO-TILE-TIMG2COL","mnemonic":"TIMG2COL","summary":"Extract an offset window from one descriptor-defined feature map into standard Left matrix order.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TIMG2COL-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TIMG2COL MUST read one valid NC1HWC0 or NDC1HWC0 source descriptor,
// derive its matrix coordinates from posM and posK, and publish one standard
// Left matrix destination atomically. Spatial or logical-channel padding MUST
// come only from the typed source descriptor, and the source descriptor MUST
// remain unchanged.
// NDF-END: PTO-TIMG2COL-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TIMG2COL() => TileOperation
begin
    return TileOperation_TIMG2COL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TIMG2COL(
    data_type: TileDataType) => boolean
begin
    return TileImg2ColDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
end;

readonly func InstructionContractHandler_TIMG2COL() => TileSemanticHandler
begin
    return TileHandler_TIMG2COL;
end;

func InstructionContractExecute_TIMG2COL(
    destination: TileIndex,
    source: TileIndex,
    position_m: integer {0..65535},
    position_k: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
    TIMG2COL(
        destination,
        source,
        position_m,
        position_k);
end;
// DOC-END: operation
