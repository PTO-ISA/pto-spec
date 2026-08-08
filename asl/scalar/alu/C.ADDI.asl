// PTO-INSTRUCTION: {"assembly":["c.addi srcL, simm, ->t"],"block":[],"catalog_indices":[32],"catalog_records":[{"asm":"c.addi srcL, simm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x000c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_addi_16_3050744f2322","length_bits":16,"mnemonic":"C.ADDI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"C.ADDI","summary":"Execute the C.ADDI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-ADDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ADDI() => ScalarOperation
begin
    return ScalarOperation_C_ADDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ADDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
