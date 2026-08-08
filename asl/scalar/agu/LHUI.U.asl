// PTO-INSTRUCTION: {"assembly":["lhui.u [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[341],"catalog_records":[{"asm":"lhui.u [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005029","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"lhui_u_32_748b15cd2ced","length_bits":32,"mnemonic":"LHUI.U","semantic_family":"AGU","semantic_group":"LDA/UNSCALED","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"LHUI.U","summary":"Execute the LHUI.U scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-LHUI-U","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LHUI_U() => ScalarOperation
begin
    return ScalarOperation_LHUI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LHUI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
