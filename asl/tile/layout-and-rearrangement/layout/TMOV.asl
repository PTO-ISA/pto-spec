// PTO-INSTRUCTION: {"assembly":["TMOV <bundle operands>"],"block":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","BSTOP"],"catalog_indices":[74],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TMOV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMOV","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TMOV","name":"TMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMOV","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","BSTOP"],"canonical_assembly":["TMOV <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TMOV schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TMOV."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TMOV is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TMOV validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}].","The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType."],"memory_effects":["Perform only the global, Local, or Shared data movement named by the mnemonic after complete access, shape, stride, and descriptor validation; a fault produces no partial destination or memory effect."],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Copy the source Tile payload and definedness into the destination.","After complete preflight, execute TMOV with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"],"engine":"TLSU","id":"PTO-TILE-TMOV","mnemonic":"TMOV","summary":"Copy the source Tile payload and definedness into the destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMOV-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local TMOV MUST copy payload and per-element definedness from one persistent
// Local source to one renamed Local destination after exact shape and carrier-width preflight.
// Shared INSERT, PUBLISH, BROADCAST, and EXTRACT modes MUST use the distinct
// BSTART.TMOV schemas and MUST preserve the accepted publication rules.
// The selected DataType MUST be a carrier interpretation. A non-packed source
// backing type MAY differ only at the same element width, and the renamed
// destination MUST preserve the source backing type.
// NDF-END: PTO-TMOV-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;

readonly func InstructionContractOperandsLegal_TMOV(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TMOV(destination, source);
end;

func InstructionContractExecute_TMOV(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TMOV(destination, source);
    TMOV(destination, source);
end;
// DOC-END: operation
