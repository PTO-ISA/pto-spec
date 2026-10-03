// PTO-INSTRUCTION: {"assembly":["TCOLSUM <bundle operands>"],"block":["BSTART.SFU TCOLSUM, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[54],"catalog_records":[{"arguments":[{"constant":"TileReduction_SUM"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TCOLSUM","operands":[{"field":"destination0","role":"new Local operation-type numeric destination"},{"field":"source0","role":"persistent Local numeric source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x050","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:new-local-operation-type-destination","operand:source0:persistent-local-numeric-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","column-reduction"],"contract":{"block_composition":["BSTART.SFU TCOLSUM, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCOLSUM <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","TCOLSUM computes a typed increasing-row left fold from zero using TADD; the scan order is architectural and tree reassociation is not permitted."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCOLSUM, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.","An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","Floating numeric status is accumulated across the architectural fold and publishes atomically with the result."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TCOLSUM is selected by the TEPL raw encoding carrier Mode 2 Function 16; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.","The operation DataType selected by BSTART is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","The destination DataType equals the selected operation DataType.","The source is a fully defined persistent numeric Tile with a legal descriptor in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; its stored backing DataType MAY differ from the operation DataType only when the unchanged TileCarrierWidthCompatible relation admits equal-width, non-packed interpretation. RCPE6M2 MUST NOT be a reduction backing. Every valid source coordinate MUST be defined and encoding-valid under the operation DataType. All valid source coordinates are checked and included in the reduction; Local CUBE ExecutionMask is unsupported and MUST reject before effects, including when mask state is injected directly into the model. For a cross-type view, backing encodings are not independently validated. The source descriptor, backing DataType, and payload persist unchanged without retagging or numeric conversion. The source capacity is checked by generic allocation and the reduction operation imposes no additional 2048-byte ceiling.","The destination has logical ValidRow equal to one and ValidCol equal to source.ValidCol. For RowMajor, Rows equals DerivedTileRows(DstCapacity, source physical Columns, DstDataType) and Columns equals source physical Columns. For CUBE_M16/M32, Rows equals source Rows and Columns equals align_up(Dst.ValidColumns, Dst CellCols), where Dst CellCols is computed from destination DataType.","Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.","An active bundle MUST resolve the operation DataType from BSTART or reject; a direct semantic call with no active bundle uses source backing DataType as the operation-type fallback.","A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local operation-type numeric destination"},{"field":"source0","role":"persistent Local numeric source"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.","The source is scanned in strictly increasing row order; the source persists and is never modified.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For each valid column, compute a typed increasing-row left fold from zero using TADD.","Write the operation-typed reduction value without widening integer arithmetic or reassociating the fold.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TCOLSUM","mnemonic":"TCOLSUM","summary":"Reduce each valid column to its sum with exact typed row-order semantics.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCOLSUM-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCOLSUM MUST select SFU Mode 2 Function 16 and MUST compute a typed
// increasing-row left fold from zero using TADD over one fully defined
// Local source.
// The source geometry MUST match the B.DIM-derived shape.
// BSTART DataType MUST be the operation DataType and MUST remain in
// the existing mnemonic-supported type set. A persistent numeric
// source backing MUST be descriptor-legal and MAY differ only when
// the unchanged TileCarrierWidthCompatible relation admits the raw
// carrier; packed/width-mismatched pairs and RCPE6M2 backing MUST
// reject. Every valid source coordinate MUST be defined and encoding-valid under
// the operation DataType. Local CUBE ExecutionMask is unsupported and
// MUST reject before effects; all valid source coordinates are checked
// and included in the reduction. Cross-type backing encodings are not
// independently validated. The source descriptor and payload
// MUST persist unchanged with no retagging or numeric conversion.
// The destination MUST use the operation DataType and integer arithmetic MUST
// remain at the selected operation element width.
// Layout and PadValueOrByteId MAY be nondefault in B.DATR.
// Complete preflight and source snapshot MUST precede atomic result,
// status, padding, and descriptor publication.
// Layout 29 selects direct Local CUBE_M32 and Layout 31 selects direct Local CUBE_M16. Omitted B.DATR and Layout=NORM retain RowMajor; all Tile operands in one operation MUST use the same layout.
// For CUBE_M16/M32, destination Rows MUST equal source Rows and destination Columns MUST equal align_up(destination ValidColumns, destination CellCols), where destination CellCols is computed from destination DataType.
// NDF-END: PTO-TCOLSUM-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLSUM() => TileOperation
begin
    return TileOperation_TCOLSUM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCOLSUM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLSUM(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLSUM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLSUM(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLSUM(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;
// DOC-END: operation
