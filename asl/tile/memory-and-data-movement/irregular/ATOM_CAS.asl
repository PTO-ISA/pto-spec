// PTO-INSTRUCTION: {"arguments":[{"constant":"GMAtomic_CAS"},{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.ATOM.CAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"GM_ATOM_CAS","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"GM_ATOM_CAS","name":"ATOM_CAS","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GM_ATOM_CAS","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices","operand:source1:expected","operand:source2:replacement"],"catalog_indices":[89],"catalog_records":[{"arguments":[{"constant":"GMAtomic_CAS"},{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.ATOM.CAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"GM_ATOM_CAS","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"GM_ATOM_CAS","name":"ATOM_CAS","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GM_ATOM_CAS","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices","operand:source1:expected","operand:source2:replacement"],"catalog_indices":[89]}],"assembly":["ATOM_CAS <bundle operands>"],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.ATOM.CAS DataType","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["ATOM_CAS <bundle operands>"],"defaults":["Function 8 preserves the 0x00811181 binary carrier; atom.cas is legal only for U16, U32, and U64."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.ATOM.CAS DataType; B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Unsupported operation/type tuples raise Fault_TileLegality before effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["atom.cas uses raw U16/U32/U64 carriers; U128 and all non-U types are rejected."],"memory_effects":["One atomic compare-and-swap per valid request."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"ordering":["Duplicate addresses serialize in implementation-defined order."],"standalone_opcode":false,"state_effects":["Returns observed old values in the destination."]},"id":"PTO-TILE-MGATHER-CAS","mnemonic":"ATOM_CAS","summary":"GM indexed atomic compare-and-swap with observed-old destination.","surface":"tile","engine":"TLSU","depends_on":["PTO-TILE-MODEL-MEMORY-ATOMICS"],"block":["BSTART.ATOM.CAS DataType","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"]}
// NDF-BEGIN: PTO-MGATHER-CAS-ATOMIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling aliases atom.cas and MUST accept only
// U16, U32, and U64 transfer DataTypes. Each valid request MUST perform one
// atomic compare-and-swap at its signed or unsigned byte displacement and
// place the value observed by that request in the corresponding destination
// element. Duplicate-address requests MUST serialize in an implementation-
// defined order and MUST NOT expose a fixed row-major ordering requirement.
// NDF-END: PTO-MGATHER-CAS-ATOMIC-001
// NDF-BEGIN: PTO-MGATHER-CAS-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling MUST preflight every valid-region read and
// write address before its first atomic effect. On success it MUST publish
// one fully defined destination whose non-valid physical elements contain the
// selected pad value.
// NDF-END: PTO-MGATHER-CAS-PUBLICATION-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_ATOM_CAS(operation: TileOperation) => boolean
begin
    return operation == TileOperation_ATOM_CAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ATOM_CAS() => TileSemanticHandler
begin
    return TileHandler_GM_ATOM_CAS;
end;
readonly func InstructionContractOperation_ATOM_CAS() => TileOperation
begin
    return TileOperation_ATOM_CAS;
end;
// DOC-END: operation
