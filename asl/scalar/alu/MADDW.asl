// PTO-INSTRUCTION: {"assembly":["maddw SrcL, SrcR, SrcD, ->{t, u, Rd}"],"block":[],"catalog_indices":[365],"catalog_records":[{"asm":"maddw SrcL, SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0600707f","match":"0x00007047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"maddw_32_9f922b15e674","length_bits":32,"mnemonic":"MADDW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyAddW","status":"accepted"}],"classification":["alu"],"mnemonic":"MADDW","summary":"Execute the MADDW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-MADDW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MADDW() => ScalarOperation
begin
    return ScalarOperation_MADDW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAddW;
end;
// DOC-END: operation
