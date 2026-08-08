// PTO-INSTRUCTION: {"assembly":["sb.pcr SrcL, [symbol]"],"block":[],"catalog_indices":[386],"catalog_records":[{"asm":"sb.pcr SrcL, [symbol]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000069","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"sb_pcr_32_7625a9a24c59","length_bits":32,"mnemonic":"SB.PCR","semantic_family":"AGU","semantic_group":"STA","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SB.PCR","summary":"Execute the SB.PCR scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SB-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SB_PCR() => ScalarOperation
begin
    return ScalarOperation_SB_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SB_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
