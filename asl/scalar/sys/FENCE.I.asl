// PTO-INSTRUCTION: {"assembly":["fence.i"],"block":[],"catalog_indices":[105],"catalog_records":[{"asm":"fence.i","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x1000202b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"fence_i_32_a321a2a186b1","length_bits":32,"mnemonic":"FENCE.I","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"FenceInstruction","status":"accepted","semantic_summary":"FENCE.I - Synchronize instruction visibility after prior writes."}],"classification":["sys"],"mnemonic":"FENCE.I","summary":"FENCE.I - Synchronize instruction visibility after prior writes.","surface":"scalar","id":"PTO-SCALAR-FENCE-I","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FENCE_I() => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENCE_I() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;
// DOC-END: operation
