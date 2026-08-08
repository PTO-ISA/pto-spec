// PTO-INSTRUCTION: {"assembly":["fmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}"],"block":[],"catalog_indices":[113],"catalog_records":[{"asm":"fmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x0000404b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcA","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fmadd_32_c616a17bcb12","length_bits":32,"mnemonic":"FMADD","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingFused","status":"accepted","semantic_summary":"FMADD - Compute this mnemonic's fused floating-point operation."}],"classification":["fsu"],"mnemonic":"FMADD","summary":"FMADD - Compute this mnemonic's fused floating-point operation.","surface":"scalar","id":"PTO-SCALAR-FMADD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FMADD() => ScalarOperation
begin
    return ScalarOperation_FMADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FMADD() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;
// DOC-END: operation
