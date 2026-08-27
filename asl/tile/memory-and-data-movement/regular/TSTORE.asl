// PTO-INSTRUCTION: {"assembly":["TSTORE <bundle operands>"],"block":["Local: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; one source B.IOT; BSTOP","Shared: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; one source B.IOS with any nonzero consumer PE_MASK; optional B.SUBVIEW; BSTOP"],"catalog_indices":[88],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TSTORE","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TSTORE","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_TSTORE","name":"TSTORE","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-bytes"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TSTORE","state_effects":["operand:address:base-address","operand:scalar0:row-stride-bytes","operand:source0:source"]}],"classification":["memory-and-data-movement","regular"],"contract":{"block_composition":["The Local form uses TLSU Function 1, exactly one terminating source B.IOT, at most one B.IOR, and no B.IOS.","The Shared form uses canonical TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero consumer PE_MASK; optional B.SUBVIEW supplies the only partial-source range.","The Local CUBE form uses Function 1, explicit B.DATR M322ND, M162ND, or N82ND with DTYPE_NONE, explicit LB0/LB1, absent LB2, and one persistent source B.IOT."],"canonical_assembly":["TSTORE <bundle operands>"],"defaults":["DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects ordinary NORM layout. Ordinary and Shared forms require PadValue zero; Local CUBE codes 24 through 26 require DTYPE_NONE, accept all four PadValue encodings, and ignore physical padding while storing only valid elements.","For an allocated source, omitted LB0, LB1, and LB2 inherit ValidCol, ValidRow, and physical Col from its descriptor. For a pending Shared source they default to 1, 1, and ValidCol.","An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.","Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP","BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP"],"exceptions":["A malformed binding stream, missing dimensions, unsupported DataType, non-row-major source, undefined Local source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects. An unpublished or not-whole-ready Shared source waits without fault or effect.","A memory translation, permission, or alignment fault is detected before the first GM write."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.IOR.RegSrc0":"An encoded zero GPR supplies base address zero; omission also defaults the base to zero but remains a distinct schema state.","B.IOR.RegSrc1":"An encoded zero GPR supplies row stride zero; omission defaults the stride to the dense byte row width derived from resolved Col and DataType.","B.IOS.PE_MASK":"0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects."},"legality":["TSTORE is selected by TLSU Function 1 and has no standalone opcode.","DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.","The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Shared source access requires whole-parent readiness and publication.","Shared PE_MASK selects participating consumer PEs and never infers quarter selection. B.SUBVIEW is the explicit source range mechanism.","ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle fits the persistent source descriptor."],"memory_effects":["For every selected PE and each element in ValidRow x ValidCol, write GM at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.","The complete selected-PE footprint is translated and permission-checked before the first GM write. A fault therefore produces no partial GM or memory-event effect."],"operands":[{"field":"source0","role":"Local Tile or absolute Shared S0..S63 source"},{"field":"address","role":"per-PE private-GPR GM base address"},{"field":"scalar0","role":"per-PE private-GPR byte row stride"}],"ordering":["Snapshot the source payload, resolve the complete schema and dimensions, validate the source descriptor or temporary descriptor, and preflight every selected GM access before storing any element.","After successful preflight, store beats have no architecture-defined relative order. Software avoids overlapping selected-PE GM regions or establishes ordering separately."],"standalone_opcode":false,"state_effects":["Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.","On success only GM and memory-event state change; the source binding is consumed by normal block completion."],"block":["Local: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; one source B.IOT; BSTOP","Shared: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; one source B.IOS with a nonzero consumer PE_MASK; optional B.SUBVIEW; BSTOP"]},"depends_on":["PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TSTORE","mnemonic":"TSTORE","summary":"Store one ordinary Local or Shared rectangle, or explicitly convert persistent Local CUBE storage into one GM rectangle.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSTORE-MEMORY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSTORE MUST use B.IOR RegSrc1 as a byte row stride, MUST snapshot and
// preserve its Local or Shared source, MUST preflight the complete selected GM
// footprint before any store, and MUST distinguish an omitted dense byte
// stride from an explicitly encoded zero stride. Function 1 Shared access
// accepts any nonzero participating PE mask, and mask zero MUST have no
// architectural effect.
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
