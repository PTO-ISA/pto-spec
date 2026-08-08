// PTO-INSTRUCTION: {"assembly":["ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[469],"catalog_records":[{"asm":"ucvtf.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000706b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"ucvtf_32_987f4e019c32","length_bits":32,"mnemonic":"UCVTF","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","status":"accepted"}],"classification":["fsu"],"mnemonic":"UCVTF","summary":"Execute the UCVTF scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-UCVTF","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_UCVTF() => ScalarOperation
begin
    return ScalarOperation_UCVTF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_UCVTF() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
// DOC-END: operation
