// PTO-INSTRUCTION: {"assembly":["fsub.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[124],"catalog_records":[{"asm":"fsub.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000104b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fsub_32_a4479d0d4276","length_bits":32,"mnemonic":"FSUB","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","status":"accepted","semantic_summary":"FSUB - Compute this mnemonic's binary floating-point operation."}],"classification":["fsu"],"mnemonic":"FSUB","summary":"FSUB - Compute this mnemonic's binary floating-point operation.","surface":"scalar","id":"PTO-SCALAR-FSUB","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FSUB() => ScalarOperation
begin
    return ScalarOperation_FSUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FSUB() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
// DOC-END: operation
