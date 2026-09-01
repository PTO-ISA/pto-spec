// PTO-INSTRUCTION: {"arguments":[{"constant":"GMReduction_POPC"},{"operand":"address"},{"operand":"source0"}],"command_mnemonic":"BSTART.RED.POPC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"GM_RED_POPC","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"GM_RED_POPC","name":"RED_POPC","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GM_RED_POPC","state_effects":["operand:address:base-address","operand:source0:indices"],"catalog_indices":[125],"catalog_records":[{"arguments":[{"constant":"GMReduction_POPC"},{"operand":"address"},{"operand":"source0"}],"command_mnemonic":"BSTART.RED.POPC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"GM_RED_POPC","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"GM_RED_POPC","name":"RED_POPC","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GM_RED_POPC","state_effects":["operand:address:base-address","operand:source0:indices"],"catalog_indices":[125]}],"assembly":["RED_POPC <bundle operands>"],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.RED.POPC DataType","B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["RED_POPC <bundle operands>"],"defaults":["GM indexed operation uses byte-displacement addresses and complete preflight."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.RED.POPC DataType"],"exceptions":["Legality and access faults occur before effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["GM-only; Shared, vector, packed, and U128 forms are rejected."],"memory_effects":["One intrinsic atomic RMW per valid request."],"operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"ordering":["Duplicate-address events serialize in implementation-defined order."],"standalone_opcode":false,"state_effects":["All valid requests take effect; atom forms publish observed old values."]},"id":"PTO-TILE-RED-POPC","mnemonic":"RED_POPC","summary":"GM indexed red.popc operation.","surface":"tile","engine":"TLSU","depends_on":["PTO-TILE-MODEL-MEMORY-ATOMICS"],"block":["BSTART.RED.POPC DataType","B.IOT IndexTile, ValueTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_RED_POPC(operation: TileOperation) => boolean
begin
    return operation == TileOperation_RED_POPC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_RED_POPC() => TileSemanticHandler
begin
    return TileHandler_GM_RED_POPC;
end;
readonly func InstructionContractOperation_RED_POPC() => TileOperation
begin
    return TileOperation_RED_POPC;
end;
// DOC-END: operation
