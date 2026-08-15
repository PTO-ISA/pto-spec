// PTO-INSTRUCTION: {"assembly":["TCOLARGMIN <bundle operands>"],"block":["BSTART.SFU TCOLARGMIN, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[67],"catalog_records":[{"arguments":[{"constant":"TileReduction_ARGMIN"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":29,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TCOLARGMIN","operands":[{"field":"destination0","role":"new Local U32 index destination"},{"field":"source0","role":"persistent Local numeric source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x05D","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:new-local-u32-index-destination","operand:source0:persistent-local-numeric-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","column-reduction"],"contract":{"block_composition":["BSTART.SFU TCOLARGMIN, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCOLARGMIN <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","TCOLARGMIN computes an increasing-row TMIN scan that retains the lowest winning index; the scan order is architectural and tree reassociation is not permitted."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCOLARGMIN, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, non-row-major source, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.","An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","Floating numeric status is accumulated across the architectural fold and publishes atomically with the result."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TCOLARGMIN is selected by the TEPL raw encoding carrier Mode 2 Function 29; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.","The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","The destination DataType is U32 regardless of source DataType.","The source is a fully defined row-major numeric Tile whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; every constrained floating encoding is valid.","The destination has ValidRow equal to one, ValidCol equal to source.ValidCol, physical Col equal to source.Col, and capacity-derived physical Rows.","PadValueOrByteId is the only applicable B.DATR field. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local U32 index destination"},{"field":"source0","role":"persistent Local numeric source"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.","The source is scanned in strictly increasing row order; the source persists and is never modified.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For each valid column, compute an increasing-row TMIN scan that retains the lowest winning index.","Write the selected row index as U32; equal winning values retain the lowest index.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-TILE-MODEL-EXECUTION-REDUCTION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TCOLARGMIN","mnemonic":"TCOLARGMIN","summary":"Reduce each valid column to its lowest minimum row index with exact typed row-order semantics.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCOLARGMIN-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCOLARGMIN MUST select SFU Mode 2 Function 29 and MUST compute an
// increasing-row TMIN scan that retains the lowest winning index over one
// fully defined Local source.
// The source geometry MUST match the B.DIM-derived shape.
// The destination MUST use U32 indices and equal winners MUST retain the
// lowest index.
// Only PadValueOrByteId MAY be nondefault in B.DATR.
// Complete preflight and source snapshot MUST precede atomic result,
// status, padding, and descriptor publication.
// NDF-END: PTO-TCOLARGMIN-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLARGMIN() => TileOperation
begin
    return TileOperation_TCOLARGMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCOLARGMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLARGMIN(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLARGMIN(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLARGMIN(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Column,
        destination,
        source);
end;
// DOC-END: operation
