// PTO-INSTRUCTION: {"assembly":["TEXTRACT <bundle operands>"],"block":["BSTART.SFU TEXTRACT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[69],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TEXTRACT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TEXTRACT","mode":3,"name":"TEXTRACT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x062","semantic_handler":"TEXTRACT","state_effects":["operand:destination0:destination","operand:source0:source","operand:natural0:row-offset","operand:natural1:column-offset"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TEXTRACT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"canonical_assembly":["TEXTRACT <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TEXTRACT schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TEXTRACT."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TEXTRACT, DataType; B.DATR (optional); B.DIM LB0; B.DIM (LB1/LB2 for 2D); B.IOT; B.IOR; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TEXTRACT is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TEXTRACT validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}]."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Extract a rectangular source region at the encoded row and column offsets.","After complete preflight, execute TEXTRACT with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TEXTRACT","mnemonic":"TEXTRACT","summary":"Extract a rectangular source region at the encoded row and column offsets.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TEXTRACT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TEXTRACT MUST copy one in-range rectangular window selected by two optional
// private-GPR offsets into one renamed Local destination.
// Omitted offsets MUST select zero. Complete preflight and source snapshot
// MUST precede atomic result, padding, and descriptor publication.
// NDF-END: PTO-TEXTRACT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;

pure func InstructionContractDataTypeLegal_TEXTRACT(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOrMove24BaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535}) => boolean
begin
    return TileOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
end;

func InstructionContractExecute_TEXTRACT(
    destination: TileIndex,
    source: TileIndex,
    row_offset: integer {0..65535},
    column_offset: integer {0..65535})
begin
    assert InstructionContractOperandsLegal_TEXTRACT(
        destination,
        source,
        row_offset,
        column_offset);
    TEXTRACT(destination, source, row_offset, column_offset);
end;
// DOC-END: operation
