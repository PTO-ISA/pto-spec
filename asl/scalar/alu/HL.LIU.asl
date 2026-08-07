// PTO-INSTRUCTION: {"assembly":["hl.liu uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[202],"catalog_records":[{"asm":"hl.liu uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x0000001d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"unsigned","width":32}],"form_id":"hl_liu_48_9dd207ce3aea","length_bits":48,"mnemonic":"HL.LIU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLongUnsigned","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.LIU","summary":"Execute the HL.LIU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LIU() => ScalarOperation
begin
    return ScalarOperation_HL_LIU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LIU() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUnsigned;
end;
// DOC-END: operation
