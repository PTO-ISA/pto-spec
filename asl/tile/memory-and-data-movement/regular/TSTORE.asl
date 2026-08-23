// PTO-INSTRUCTION: {"assembly":["TSTORE <bundle operands>"],"block":["Local: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; one source B.IOT; BSTOP","Shared full: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; one source B.IOS with PE_MASK=1111; BSTOP","Shared partial: BSTART.TSTORE DataType using Function 14; optional B.DATR/B.DIM/B.IOR; one source B.IOS with any nonzero PE subset; BSTOP"],"catalog_indices":[88],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TSTORE","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TSTORE","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_TSTORE","name":"TSTORE","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-bytes"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TSTORE","state_effects":["operand:address:base-address","operand:scalar0:row-stride-bytes","operand:source0:source"]}],"classification":["memory-and-data-movement","regular"],"contract":{"block_composition":["The Local form uses TLSU Function 1, exactly one terminating source B.IOT, at most one B.IOR, and no B.IOS.","The Shared full form uses TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and PE_MASK=1111 for every nonzero access.","The Shared partial form uses TLSU Function 14 (TSTORE.SPART), exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero PE subset.","The Local CUBE form uses Function 1, explicit B.DATR M322ND, M162ND, or N82ND with DTYPE_NONE, explicit LB0/LB1, absent LB2, and one persistent source B.IOT."],"canonical_assembly":["TSTORE <bundle operands>"],"defaults":["DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects ordinary NORM layout. Ordinary and Shared forms require PadValue zero; Local CUBE codes 24 through 26 require DTYPE_NONE, accept all four PadValue encodings, and ignore physical padding while storing only valid elements.","For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For an unallocated Shared source they default to 1, 1, and ValidCol.","An unallocated Shared source derives the smallest legal 128 B through 8 KiB per-PE capacity containing the completed shape. The temporary descriptor supplies undefined-register values and is never written back.","Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP","BSTART.TSTORE FP16; B.IOS S7, mask=1111; BSTOP","BSTART.TSTORE FP16 using Function 14; B.IOS S7, mask=0011; BSTOP","BSTART.TSTORE FP16; B.DATR {M162ND, DTYPE_NONE, Null, EQ, Default, 0, 0}; B.DIM LB0=N; B.DIM LB1=M; B.IOT M#1, mask=1111, <last>; BSTOP"],"exceptions":["Reserved DataType, unsupported Layout, invalid dimensions, source descriptor mismatch, malformed bindings, illegal PE mask, or GM translation, permission, or alignment fault raises Illegal Block Exception or the applicable data fault before the first GM write.","An unallocated or selected-quarter-uninitialized Shared source is not an exception; it reads as an undefined register through a non-mutating operation-derived descriptor."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.IOR.RegSrc0":"An encoded zero GPR supplies base address zero; omission also defaults the base to zero but remains a distinct schema state.","B.IOR.RegSrc1":"An encoded zero GPR supplies row stride zero; omission defaults the stride to the dense byte row width derived from resolved Col and DataType.","B.IOS.PE_MASK":"0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects."},"legality":["TSTORE is selected only by BSTART.TSTORE/TLSU Function 1 or the Function 14 TSTORE.SPART variant and has no standalone opcode.","DataType accepts 0..14, 16..20, and 24..28; codes 15, 21..23, and 29..31 are reserved and reject before effects.","The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Function 14 accepts only one Shared B.IOS. Source/destination role mismatches and mixed domains are illegal.","A nonzero Function 1 Shared store requires PE_MASK=1111. Function 14 accepts every nonzero subset. PE_MASK=0000 is a strict no-op.","ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the valid rectangle fits the persistent source descriptor or the derived temporary Shared descriptor.","Ordinary forms require nonzero ValidCol and ValidRow, ValidCol not greater than physical Col, and a valid rectangle fitting the source descriptor. Local CUBE forms require explicit nonzero LB0/LB1, absent LB2, and an exact persistent Matrix descriptor matching code, dtype, and shape.","Ordinary and Shared forms require PadValue zero. Local CUBE codes 24 through 26 accept all four PadValue encodings, require DTYPE_NONE, and ignore physical padding while storing the valid rectangle only."],"memory_effects":["For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.","The complete selected-PE footprint is translated and permission-checked before the first GM write. A fault therefore produces no partial GM or memory-event effect."],"operands":[{"field":"source0","role":"Local Tile or absolute Shared S0..S63 source"},{"field":"address","role":"per-PE private-GPR GM base address"},{"field":"scalar0","role":"per-PE private-GPR byte row stride"}],"ordering":["Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and preflight every selected GM access before storing any element.","After successful preflight, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately."],"standalone_opcode":false,"state_effects":["Read one Local or Shared source without modifying its payload, descriptor, allocation mask, initialized mask, or lifetime.","A Shared undefined-source read remains non-allocating and non-mutating. On success only GM and memory-event state change; normal block completion consumes the source binding, not the Tile value.","A successful CUBE form stores raw valid values through CUBE storage indices and never writes or changes physical padding, payload, descriptor, allocation mask, or definedness."]},"depends_on":["PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TSTORE","mnemonic":"TSTORE","summary":"Store one ordinary Local or Shared rectangle, or explicitly convert persistent Local CUBE storage into one GM rectangle.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSTORE-MEMORY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSTORE MUST use B.IOR RegSrc1 as a byte row stride, MUST snapshot and
// preserve its Local or Shared source, MUST preflight the complete selected GM
// footprint before any store, and MUST distinguish an omitted dense byte
// stride from an explicitly encoded zero stride. Function 1
// Shared access MUST require mask 1111, Function 14 MUST accept every nonzero
// subset, and mask zero MUST have no architectural effect.
// NDF-END: PTO-TSTORE-MEMORY-001
// NDF-BEGIN: PTO-TSTORE-CUBE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// CUBE TSTORE MUST require an exact persistent Matrix descriptor selected by
// M322ND, M162ND, or N82ND, MUST preflight its full LB1 by LB0 GM footprint,
// and MUST store only valid elements without modifying source or padding.
// NDF-END: PTO-TSTORE-CUBE-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSTORE(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word,
    row: integer {0..65535},
    column: integer {0..65535},
    row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TSTORE(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;

pure func InstructionContractZeroMaskNoEffect_TSTORE(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractCubeDimensionsLegal_TSTORE(
    lb0_present: boolean, lb0: integer {0..65535},
    lb1_present: boolean, lb1: integer {0..65535},
    lb2_present: boolean) => boolean
begin
    return lb0_present && lb0 != 0 &&
           lb1_present && lb1 != 0 && !lb2_present;
end;
// DOC-END: operation
