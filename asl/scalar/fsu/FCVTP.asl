// PTO-INSTRUCTION: {"assembly":["fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[101],"catalog_records":[{"asm":"fcvtp.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000406b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fcvtp_32_84354a7aa6b1","length_bits":32,"mnemonic":"FCVTP","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","status":"accepted","semantic_summary":"FCVTP - Convert between the encoded scalar numeric formats."}],"classification":["fsu"],"mnemonic":"FCVTP","summary":"FCVTP - Convert between the encoded scalar numeric formats.","surface":"scalar","id":"PTO-SCALAR-FCVTP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FCVTP() => ScalarOperation
begin
    return ScalarOperation_FCVTP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FCVTP() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
// DOC-END: operation
