// PTO-INSTRUCTION: {"assembly":["sw.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"block":[],"catalog_indices":[455],"catalog_records":[{"asm":"sw.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00006049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sw_u_32_718a61f75d33","length_bits":32,"mnemonic":"SW.U","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"SW.U - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"SW.U","summary":"SW.U - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-SW-U","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW_U() => ScalarOperation
begin
    return ScalarOperation_SW_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
