// PTO-INSTRUCTION: {"assembly":["sdi.u SrcL, [SrcR, simm]"],"block":[],"catalog_indices":[405],"catalog_records":[{"asm":"sdi.u SrcL, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007059","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"sdi_u_32_cba5a4a04e7b","length_bits":32,"mnemonic":"SDI.U","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SDI.U","summary":"Execute the SDI.U scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SDI-U","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SDI_U() => ScalarOperation
begin
    return ScalarOperation_SDI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
