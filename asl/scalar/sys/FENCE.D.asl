// PTO-INSTRUCTION: {"assembly":["fence.d pred_imm, succ_imm"],"block":[],"catalog_indices":[104],"catalog_records":[{"asm":"fence.d pred_imm, succ_imm","constraints":[],"encoding":[{"index":0,"mask":"0xf00fffff","match":"0x0000202b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"PRED_IMM","pieces":[{"instruction_lsb":24,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4},{"name":"SUCC_IMM","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"fence_d_32_f4783f17d84d","length_bits":32,"mnemonic":"FENCE.D","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"FenceData","status":"accepted","semantic_summary":"FENCE.D - Order the selected predecessor and successor data-access classes."}],"classification":["sys"],"mnemonic":"FENCE.D","summary":"FENCE.D - Order the selected predecessor and successor data-access classes.","surface":"scalar","id":"PTO-SCALAR-FENCE-D","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FENCE_D() => ScalarOperation
begin
    return ScalarOperation_FENCE_D;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENCE_D() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceData;
end;
// DOC-END: operation
