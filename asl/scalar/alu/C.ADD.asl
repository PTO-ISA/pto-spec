// PTO-INSTRUCTION: {"assembly":["c.add srcL, srcR, ->t"],"block":[],"catalog_indices":[31],"catalog_records":[{"asm":"c.add srcL, srcR, ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0008","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_add_16_85136d1e4904","length_bits":16,"mnemonic":"C.ADD","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"C.ADD","summary":"Execute the C.ADD scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ADD() => ScalarOperation
begin
    return ScalarOperation_C_ADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
