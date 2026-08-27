// PTO-INSTRUCTION: {"assembly":["THISTOGRAM <bundle operands>"],"block":["BSTART.SFU THISTOGRAM, U16|U32","B.DATR DstDataType=U32, ByteId=0..3 (mandatory)","B.IOT SourceTile, FilterTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[74],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"selected_byte"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","DataType"],"pad_union":"histogram-byte-id"},"disposition":"accepted-direct-operation","effect_contract":"THISTOGRAM","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_THISTOGRAM","mode":3,"name":"THISTOGRAM","operands":[{"field":"destination0","role":"new Local U32 prefix-histogram destination"},{"field":"source0","role":"persistent Local U16 or U32 source"},{"field":"source1","role":"persistent Local U8 prefix filter"},{"field":"selected_byte","role":"B.DATR ByteId zero through three"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x068","semantic_handler":"THISTOGRAM","state_effects":["operand:destination0:new-local-u32-prefix-histogram-destination","operand:source0:persistent-local-u16-or-u32-source","operand:source1:persistent-local-u8-prefix-filter","operand:selected_byte:histogram-byte-id","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","initialization"],"contract":{"block_composition":["BSTART.SFU THISTOGRAM, U16|U32","B.DATR DstDataType=U32, ByteId=0..3 (mandatory)","B.IOT SourceTile, FilterTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["THISTOGRAM <bundle operands>"],"defaults":["BSTART explicitly selects source DataType U16 or U32. B.DATR is mandatory: its secondary DataType must be U32 and PadValueOrByteId supplies ByteId 0 through 3.","No B.IOR or B.DIM is permitted. Exactly one terminating Local B.IOT supplies source, filter, and a newly allocated destination.","The filter binding is structurally mandatory. U16 ByteId1 and U32 ByteId3 are unfiltered and do not read filter shape, payload, or definedness.","Physical destination padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU THISTOGRAM, U16; B.DATR U32, ByteId=0; B.IOT T0, T1, mask=1111, <last>, ->T2<4>; BSTOP"],"exceptions":["Malformed bindings, B.IOR, B.IOS, B.DIM, omitted B.DATR, unsupported source or destination DataType, illegal ByteId for U16, descriptor mismatch, undefined consumed source or filter data, shape mismatch, capacity failure, or allocation failure raises the applicable Tile fault before effects.","U16 ByteId2 and ByteId3 are reserved for this operation and raise Fault_TileLegality before allocation or payload effects.","PE_MASK zero completes as a strict no-op before schema, descriptor, filter, allocation, fault, or payload checks."],"field_contracts":{"BSTART.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.DataType":"Encoded zero is FP64 and is illegal; THISTOGRAM requires explicit U32.","B.DATR.PadValueOrByteId":"ByteId zero selects the least-significant source byte and the longest required prefix."},"legality":["THISTOGRAM is selected by the TEPL encoding carrier Mode 3 Function 8, is canonically assembled with BSTART.SFU, and has no standalone opcode.","The source is a fully defined row-major numeric Local U16 or U32 Tile. The filter is a numeric Local U8 Tile whose logical layout is honored.","The newly allocated destination is row-major U32 with ValidRow equal to source ValidRow, ValidCol exactly 256, physical Row at least ValidRow, physical Col at least 256, and sufficient capacity.","For U16, ByteId0 requires one defined filter element at logical [row,0] for every source row; ByteId1 is unfiltered. ByteId2 and ByteId3 are illegal.","For U32, ByteId2, ByteId1, and ByteId0 require respectively one, two, and three defined global prefix bytes at filter logical [0,0], [1,0], and [2,0]; ByteId3 is unfiltered.","The destination must be distinct from source and filter. Source and filter persist."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local U32 prefix-histogram destination"},{"field":"source0","role":"persistent Local U16 or U32 source"},{"field":"source1","role":"persistent Local U8 prefix filter"},{"field":"selected_byte","role":"B.DATR ByteId zero through three"}],"ordering":["Complete schema, attribute, mask, type, descriptor, consumed-definedness, shape, capacity, destination-name, and allocation preflight precedes every snapshot and effect.","The complete source and consumed filter payloads are snapshotted before histogram evaluation. The U32 payload, Null padding definedness, and destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For each source row, consider only values passing the selected ByteId filter and count the selected source byte into 256 bins.","U16 ByteId0 matches the source high byte against filter[row,0] and histograms the low byte; U16 ByteId1 histograms the high byte without reading filter data.","U32 ByteId2, ByteId1, and ByteId0 match the more-significant one, two, or three bytes against the global filter prefix before histogramming the selected byte; ByteId3 is unfiltered.","Destination element [row,bin] is the inclusive cumulative count from bin zero through bin. Every physical coordinate outside the valid rectangle is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-HISTOGRAM-SCHEMA","PTO-TILE-MODEL-EXECUTION-COMPLEX"],"engine":"SFU","id":"PTO-TILE-THISTOGRAM","mnemonic":"THISTOGRAM","summary":"Build one inclusive 256-bin U32 prefix histogram per source row after the ByteId-specific filter.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-THISTOGRAM-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// THISTOGRAM MUST select SFU Mode 3 Function 8. It MUST consume one row-major
// Local U16 or U32 source, one structurally present Local U8 filter, and one
// mandatory B.DATR whose destination DataType is U32 and whose ByteId is
// operation-legal. It MUST publish one inclusive 256-bin U32 prefix histogram
// per source row only after complete preflight and source/filter snapshots.
// NDF-END: PTO-THISTOGRAM-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractSourceDataTypeLegal_THISTOGRAM(
    data_type: TileDataType) => boolean
begin
    return TileHistogramSourceDataTypeSupported(data_type);
end;

pure func InstructionContractSelectedByteLegal_THISTOGRAM(
    data_type: TileDataType,
    selected_byte: integer {0..3}) => boolean
begin
    return TileHistogramSelectedByteSupported(
        data_type,
        selected_byte);
end;

readonly func InstructionContractOperandsLegal_THISTOGRAM(
    destination: TileIndex,
    source: TileIndex,
    filter: TileIndex,
    selected_byte: integer {0..3}) => boolean
begin
    return TileOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
end;

readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;

func InstructionContractExecute_THISTOGRAM(
    destination: TileIndex,
    source: TileIndex,
    filter: TileIndex,
    selected_byte: integer {0..3})
begin
    assert InstructionContractOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
    THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
end;
// DOC-END: operation
