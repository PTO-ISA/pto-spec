// PTO-INSTRUCTION: {"assembly":["lwui.u [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[363],"catalog_records":[{"asm":"lwui.u [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00006029","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"lwui_u_32_1fcbb98df571","length_bits":32,"mnemonic":"LWUI.U","semantic_family":"AGU","semantic_group":"LDA/UNSCALED","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"LWUI.U","summary":"Execute the LWUI.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LWUI_U() => ScalarOperation
begin
    return ScalarOperation_LWUI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LWUI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
