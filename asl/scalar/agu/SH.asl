// PTO-INSTRUCTION: {"assembly":["sh SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1]"],"block":[],"catalog_indices":[424],"catalog_records":[{"asm":"sh SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<1]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00001049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sh_32_bc7d4a7dea28","length_bits":32,"mnemonic":"SH","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"SH - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"SH","summary":"SH - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-SH","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SH() => ScalarOperation
begin
    return ScalarOperation_SH;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SH() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
