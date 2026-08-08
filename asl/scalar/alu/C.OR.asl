// PTO-INSTRUCTION: {"assembly":["c.or srcL, srcR, ->t"],"block":[],"catalog_indices":[41],"catalog_records":[{"asm":"c.or srcL, srcR, ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0038","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_or_16_90864d13a661","length_bits":16,"mnemonic":"C.OR","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"C.OR","summary":"Execute the C.OR scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-OR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_OR() => ScalarOperation
begin
    return ScalarOperation_C_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
