// PTO-INSTRUCTION: {"assembly":["TLOAD <bundle operands>"],"block":["# Local destination","BSTART.TLOAD DataType","optional B.DATR Layout","B.DIM LB0=ValidCol, LB1=ValidRow, LB2=Col","optional B.IOR RegSrc0=base, RegSrc1=row_stride_elements","one terminating destination B.IOT","BSTOP","# Shared destination","replace B.IOT with one destination B.IOS"],"catalog_indices":[87],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TLOAD","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TLOAD","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TLOAD","name":"TLOAD","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TLOAD","state_effects":["operand:destination0:destination","operand:address:base-address","operand:scalar0:row-stride-elements"]}],"classification":["memory-and-data-movement","regular"],"contract":{"block_composition":["Local: BSTART.TLOAD DataType; optional B.DATR Layout; B.DIM defines ValidCol, ValidRow, and physical Col; optional B.IOR defines the per-PE GM base and logical-element row stride; one terminating destination B.IOT allocates the result; BSTOP commits.","Shared: replace B.IOT with one destination B.IOS carrying absolute S0..S255, per-PE TSize, and PE_MASK. Local sources, Shared sources, multiple destinations, and mixed destination domains are illegal."],"canonical_assembly":["TLOAD <bundle operands>"],"defaults":["DataType is explicit in BSTART.TLOAD. Omitted B.DATR selects NORM layout; TLOAD does not consume PadValue.","LB0/ValidCol and LB1/ValidRow default through the common destination-shape rules. Omitted LB2/Col defaults to ValidCol. Rows are derived from TSize, Col, and DataType and must contain ValidRow.","Omitted B.IOR supplies base zero and dense row stride equal to resolved Col. An encoded zero GPR selector is present and reads zero, so an explicitly encoded zero stride aliases rows rather than selecting the omission default."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TLOAD U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR zero, a0; B.IOT mask=1111, ->T<1>; BSTOP","BSTART.TLOAD FP16; B.DIM LB0, 32; B.DIM LB1, 4; B.IOS mask=0011, ->S7<1>; BSTOP"],"exceptions":["Reserved DataType, unsupported Layout, nonzero PadValue, malformed B.IOR/B.IOT/B.IOS schema, invalid dimensions, capacity or shape overflow, allocation failure, or GM translation, permission, or alignment fault rejects before destination publication.","Every selected memory address is preflighted before any destination payload, descriptor, allocation, definedness, or load event becomes visible. A failed Local allocation is rolled back; a failed Shared update preserves the prior Shared record."],"field_contracts":{},"field_zero_meanings":{},"legality":["TLOAD is selected only by TLSU Function 0 through BSTART.TLOAD; it has no standalone opcode.","The completed block has exactly one destination domain: one terminating destination B.IOT for Local or one destination B.IOS for Shared. It has no Tile source and consumes at most one B.IOR.","The BSTART DataType accepts every assigned Tile DataType code and rejects 15, 21..23, and 29..31 before effects. B.DATR may change only Layout; every other explicit nonzero B.DATR field is illegal.","ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the derived Rows and Col are powers of two large enough for the valid rectangle.","PE_MASK=0000 is a strict no-op before GPR reads, allocation, memory access, faults, load events, descriptor changes, or payload changes."],"memory_effects":["For each selected PE and each element in ValidRow x ValidCol, read GM at base + ((row * row_stride_elements + column) * element_size). Packed four-bit types apply the logical index first and then select the addressed nibble.","The accesses participate in PTO-TSO using the block aq/rl attributes and are precise and restartable."],"operands":[{"field":"destination0","role":"new Local destination or absolute Shared destination"},{"field":"address","role":"per-PE private-GPR GM base address"},{"field":"scalar0","role":"per-PE private-GPR logical row stride in elements"}],"ordering":["Resolve the complete schema, selected PE mask, per-PE GPR inputs, dimensions, destination capacity, and all memory translations before the first architectural load effect.","On success publish the complete Local destination or the selected Shared quarters atomically at block commit. Unselected Shared quarters remain unchanged; on failure the prior destination and restart-visible block state are preserved."],"standalone_opcode":false,"state_effects":["A successful Local form allocates or renames exactly one destination Tile, installs the derived descriptor, loads every selected valid element, and marks the valid region defined.","A successful Shared form reallocates the named S register when required and updates only the quarters selected by PE_MASK. TLOAD does not modify source GPRs or GM." ]},"depends_on":["PTO-BLOCK-BSTART-TLOAD","PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TLOAD","mnemonic":"TLOAD","summary":"Load one Local or Shared Tile valid rectangle from GM using per-PE base addresses and logical row strides.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TLOAD-MEMORY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLOAD MUST use B.IOR RegSrc0 as the per-PE GM base and RegSrc1 as the
// logical-element row stride, MUST distinguish omission from encoded zero,
// MUST preflight the entire selected footprint, and MUST publish exactly one
// Local destination or selected Shared quarters only after success.
// NDF-END: PTO-TLOAD-MEMORY-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TLOAD(code: bits(5)) => boolean
begin
    return TileDataTypeEncodingValid(code as TileDataTypeEncoding);
end;

pure func InstructionContractDestinationShapeLegal_TLOAD(
    size_code: integer {1..7}, columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    return TileDescriptorShapeLegal(TileSizeCodeBytes(size_code), columns,
        valid_rows, valid_columns, data_type);
end;

readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;

readonly func InstructionContractGMAddress_TLOAD(
    base_address: Word, row: integer {0..65535},
    column: integer {0..65535}, row_stride_elements: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryIndexedAddress(base_address,
        TileMemoryStridedIndex(row, column, row_stride_elements), data_type);
end;

readonly func InstructionContractDenseStride_TLOAD(
    columns: integer {0..262144}) => Word
begin
    return NaturalToWord(columns);
end;

pure func InstructionContractZeroMaskNoEffect_TLOAD(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;
// DOC-END: operation
