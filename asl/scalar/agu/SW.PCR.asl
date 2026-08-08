// PTO-INSTRUCTION: {"assembly":["sw.pcr SrcL, [symbol]"],"block":[],"catalog_indices":[452],"catalog_records":[{"asm":"sw.pcr SrcL, [symbol]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002069","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"sw_pcr_32_436677679523","length_bits":32,"mnemonic":"SW.PCR","semantic_family":"AGU","semantic_group":"STA","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SW.PCR","summary":"Execute the SW.PCR scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SW-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW_PCR() => ScalarOperation
begin
    return ScalarOperation_SW_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
